import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Protocol

protocol GrowthObjectRepositoryProtocol {
    func createGrowthObject(_ obj: GrowthObject) async throws
    func fetchGrowthObject(for pairLinkID: String) async throws -> GrowthObject?
    func addPoints(growthObjectID: String, points: Int) async throws
    func listenGrowthObject(for pairLinkID: String, onChange: @escaping (GrowthObject?) -> Void) -> Any?
}

// MARK: - Live Implementation

final class GrowthObjectRepository: GrowthObjectRepositoryProtocol {
    private let collection = "growthObjects"

    func createGrowthObject(_ obj: GrowthObject) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        let data = encode(obj)
        try await Firestore.firestore().collection(collection).document(obj.id).setData(data)
        #endif
    }

    func fetchGrowthObject(for pairLinkID: String) async throws -> GrowthObject? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        let query = try await Firestore.firestore().collection(collection)
            .whereField("pairLinkID", isEqualTo: pairLinkID)
            .limit(to: 1)
            .getDocuments()
        guard let doc = query.documents.first else { return nil }
        return decode(id: doc.documentID, data: doc.data())
        #else
        return nil
        #endif
    }

    /// Firestore transaction で競合・二重加算を防ぐ
    func addPoints(growthObjectID: String, points: Int) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        let ref = Firestore.firestore().collection(collection).document(growthObjectID)
        _ = try await Firestore.firestore().runTransaction { transaction, errorPointer -> Any? in
            do {
                let snapshot = try transaction.getDocument(ref)
                let current = snapshot.data()?["growthPoints"] as? Int ?? 0
                transaction.updateData(
                    [
                        "growthPoints": current + points,
                        "lastActionAt": Timestamp(date: .now)
                    ],
                    forDocument: ref
                )
            } catch {
                errorPointer?.pointee = error as NSError
            }
            return nil
        }
        #endif
    }

    func listenGrowthObject(for pairLinkID: String, onChange: @escaping (GrowthObject?) -> Void) -> Any? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        return Firestore.firestore().collection(collection)
            .whereField("pairLinkID", isEqualTo: pairLinkID)
            .addSnapshotListener { snapshot, _ in
                if let doc = snapshot?.documents.first {
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

    private func encode(_ obj: GrowthObject) -> [String: Any] {
        var data: [String: Any] = [
            "pairLinkID": obj.pairLinkID,
            "type": obj.type.rawValue,
            "name": obj.name,
            "growthPoints": obj.growthPoints,
        ]
        if let last = obj.lastActionAt { data["lastActionAt"] = firestoreTimestamp(from: last) }
        return data
    }

    private func decode(id: String, data: [String: Any]) -> GrowthObject {
        GrowthObject(
            id: id,
            pairLinkID: data["pairLinkID"] as? String ?? "",
            type: GrowthObjectType(rawValue: data["type"] as? String ?? "") ?? .flower,
            name: data["name"] as? String ?? "はぐる",
            growthPoints: data["growthPoints"] as? Int ?? 0,
            lastActionAt: firestoreDate(from: data["lastActionAt"])
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

final class MockGrowthObjectRepository: GrowthObjectRepositoryProtocol {
    var objects: [GrowthObject] = [.mockFlower]

    func createGrowthObject(_ obj: GrowthObject) async throws { objects.append(obj) }

    func fetchGrowthObject(for pairLinkID: String) async throws -> GrowthObject? {
        objects.first { $0.pairLinkID == pairLinkID }
    }

    func addPoints(growthObjectID: String, points: Int) async throws {
        if let idx = objects.firstIndex(where: { $0.id == growthObjectID }) {
            objects[idx].growthPoints += points
            objects[idx].lastActionAt = .now
        }
    }

    func listenGrowthObject(for pairLinkID: String, onChange: @escaping (GrowthObject?) -> Void) -> Any? {
        onChange(objects.first { $0.pairLinkID == pairLinkID })
        return nil
    }
}
