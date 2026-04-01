import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Protocol

protocol PairLinkRepositoryProtocol {
    func createPairLink(_ link: PairLink) async throws
    func fetchPairLink(for userID: String) async throws -> PairLink?
    func fetchPairLink(byCode code: String) async throws -> PairLink?
    func connectPair(pairLinkID: String, childUserID: String) async throws
    func listenPairLink(for userID: String, onChange: @escaping (PairLink?) -> Void) -> Any?
}

// MARK: - Live Implementation

final class PairLinkRepository: PairLinkRepositoryProtocol {
    private let collection = "pairLinks"

    func createPairLink(_ link: PairLink) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        let data = encode(link)
        try await Firestore.firestore().collection(collection).document(link.id).setData(data)
        #endif
    }

    func fetchPairLink(for userID: String) async throws -> PairLink? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        let db = Firestore.firestore()

        // Search as parent
        let parentQuery = try await db.collection(collection)
            .whereField("parentUserID", isEqualTo: userID)
            .whereField("inviteStatus", in: ["pending", "connected"])
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments()

        if let doc = parentQuery.documents.first {
            return decode(id: doc.documentID, data: doc.data())
        }

        // Search as child
        let childQuery = try await db.collection(collection)
            .whereField("childUserID", isEqualTo: userID)
            .whereField("inviteStatus", isEqualTo: "connected")
            .order(by: "createdAt", descending: true)
            .limit(to: 1)
            .getDocuments()

        if let doc = childQuery.documents.first {
            return decode(id: doc.documentID, data: doc.data())
        }

        return nil
        #else
        return nil
        #endif
    }

    func fetchPairLink(byCode code: String) async throws -> PairLink? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        let query = try await Firestore.firestore().collection(collection)
            .whereField("inviteCode", isEqualTo: code)
            .whereField("inviteStatus", isEqualTo: "pending")
            .limit(to: 1)
            .getDocuments()

        guard let doc = query.documents.first else { return nil }
        return decode(id: doc.documentID, data: doc.data())
        #else
        return nil
        #endif
    }

    func connectPair(pairLinkID: String, childUserID: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        try await Firestore.firestore().collection(collection).document(pairLinkID).updateData([
            "childUserID": childUserID,
            "inviteStatus": InviteStatus.connected.rawValue
        ])
        #endif
    }

    func listenPairLink(for userID: String, onChange: @escaping (PairLink?) -> Void) -> Any? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        return Firestore.firestore().collection(collection)
            .whereField("parentUserID", isEqualTo: userID)
            .addSnapshotListener { snapshot, _ in
                let doc = snapshot?.documents.first
                if let doc {
                    onChange(self.decode(id: doc.documentID, data: doc.data()))
                } else {
                    onChange(nil)
                }
            }
        #else
        return nil
        #endif
    }

    // MARK: - Encoding / Decoding

    private func encode(_ link: PairLink) -> [String: Any] {
        var data: [String: Any] = [
            "parentUserID": link.parentUserID,
            "relationshipType": link.relationshipType.rawValue,
            "inviteCode": link.inviteCode,
            "inviteStatus": link.inviteStatus.rawValue,
            "createdAt": firestoreTimestamp(from: link.createdAt)
        ]
        if let childID = link.childUserID { data["childUserID"] = childID }
        return data
    }

    private func decode(id: String, data: [String: Any]) -> PairLink {
        PairLink(
            id: id,
            parentUserID: data["parentUserID"] as? String ?? "",
            childUserID: data["childUserID"] as? String,
            relationshipType: RelationshipType(rawValue: data["relationshipType"] as? String ?? "") ?? .other,
            inviteCode: data["inviteCode"] as? String ?? "",
            inviteStatus: InviteStatus(rawValue: data["inviteStatus"] as? String ?? "") ?? .pending,
            createdAt: firestoreDate(from: data["createdAt"]) ?? .now
        )
    }

    private func firestoreTimestamp(from date: Date) -> Any {
        #if canImport(FirebaseFirestore)
        return Timestamp(date: date)
        #else
        return date.timeIntervalSince1970
        #endif
    }

    private func firestoreDate(from value: Any?) -> Date? {
        #if canImport(FirebaseFirestore)
        return (value as? Timestamp)?.dateValue()
        #else
        if let interval = value as? TimeInterval { return Date(timeIntervalSince1970: interval) }
        return nil
        #endif
    }
}

// MARK: - Mock

final class MockPairLinkRepository: PairLinkRepositoryProtocol {
    var links: [PairLink] = [.mockConnected]

    func createPairLink(_ link: PairLink) async throws { links.append(link) }

    func fetchPairLink(for userID: String) async throws -> PairLink? {
        links.first { $0.parentUserID == userID || $0.childUserID == userID }
    }

    func fetchPairLink(byCode code: String) async throws -> PairLink? {
        links.first { $0.inviteCode == code }
    }

    func connectPair(pairLinkID: String, childUserID: String) async throws {
        if let idx = links.firstIndex(where: { $0.id == pairLinkID }) {
            links[idx].childUserID = childUserID
            links[idx].inviteStatus = .connected
        }
    }

    func listenPairLink(for userID: String, onChange: @escaping (PairLink?) -> Void) -> Any? {
        onChange(links.first { $0.parentUserID == userID || $0.childUserID == userID })
        return nil
    }
}
