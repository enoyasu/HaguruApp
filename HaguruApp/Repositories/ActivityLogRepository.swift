import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Protocol

protocol ActivityLogRepositoryProtocol {
    func postLog(_ log: ActivityLog) async throws
    func fetchLogs(for growthObjectID: String, limit: Int) async throws -> [ActivityLog]
    func listenLogs(for growthObjectID: String, onChange: @escaping ([ActivityLog]) -> Void) -> Any?
}

// MARK: - Live Implementation

final class ActivityLogRepository: ActivityLogRepositoryProtocol {
    private let collection = "activityLogs"

    func postLog(_ log: ActivityLog) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        let data = encode(log)
        try await Firestore.firestore().collection(collection).document(log.id).setData(data)
        #endif
    }

    func fetchLogs(for growthObjectID: String, limit: Int = 50) async throws -> [ActivityLog] {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return [] }
        let query = try await Firestore.firestore().collection(collection)
            .whereField("growthObjectID", isEqualTo: growthObjectID)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
            .getDocuments()
        return query.documents.compactMap { decode(id: $0.documentID, data: $0.data()) }
        #else
        return []
        #endif
    }

    func listenLogs(for growthObjectID: String, onChange: @escaping ([ActivityLog]) -> Void) -> Any? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        return Firestore.firestore().collection(collection)
            .whereField("growthObjectID", isEqualTo: growthObjectID)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { snapshot, _ in
                let logs = snapshot?.documents.compactMap {
                    self.decode(id: $0.documentID, data: $0.data())
                } ?? []
                onChange(logs)
            }
        #else
        return nil
        #endif
    }

    // MARK: - Encoding / Decoding

    private func encode(_ log: ActivityLog) -> [String: Any] {
        var data: [String: Any] = [
            "growthObjectID": log.growthObjectID,
            "actorUserID": log.actorUserID,
            "actorNickname": log.actorNickname,
            "actionType": log.actionType.rawValue,
            "createdAt": firestoreTimestamp(from: log.createdAt)
        ]
        if let text = log.text { data["text"] = text }
        if let stamp = log.stampType { data["stampType"] = stamp.rawValue }
        if let url = log.imageURL { data["imageURL"] = url }
        return data
    }

    private func decode(id: String, data: [String: Any]) -> ActivityLog? {
        guard let actionTypeRaw = data["actionType"] as? String,
              let actionType = ActionType(rawValue: actionTypeRaw) else { return nil }

        return ActivityLog(
            id: id,
            growthObjectID: data["growthObjectID"] as? String ?? "",
            actorUserID: data["actorUserID"] as? String ?? "",
            actorNickname: data["actorNickname"] as? String ?? "",
            actionType: actionType,
            text: data["text"] as? String,
            stampType: StampType(rawValue: data["stampType"] as? String ?? ""),
            imageURL: data["imageURL"] as? String,
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

final class MockActivityLogRepository: ActivityLogRepositoryProtocol {
    var logs: [ActivityLog] = ActivityLog.mockLogs

    func postLog(_ log: ActivityLog) async throws { logs.insert(log, at: 0) }

    func fetchLogs(for growthObjectID: String, limit: Int = 50) async throws -> [ActivityLog] {
        Array(logs.filter { $0.growthObjectID == growthObjectID }.prefix(limit))
    }

    func listenLogs(for growthObjectID: String, onChange: @escaping ([ActivityLog]) -> Void) -> Any? {
        onChange(logs.filter { $0.growthObjectID == growthObjectID })
        return nil
    }
}
