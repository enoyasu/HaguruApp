import Foundation

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - Protocol

protocol UserRepositoryProtocol {
    func saveUser(_ user: HaguruUser) async throws
    func fetchUser(id: String) async throws -> HaguruUser?
    func updateNickname(userID: String, nickname: String) async throws
    func updateProfileIcon(userID: String, icon: String) async throws
}

// MARK: - Live Implementation

final class UserRepository: UserRepositoryProtocol {
    private let collection = "users"

    func saveUser(_ user: HaguruUser) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        let data = encode(user)
        try await Firestore.firestore().collection(collection).document(user.id).setData(data)
        #endif
    }

    func fetchUser(id: String) async throws -> HaguruUser? {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return nil }
        let doc = try await Firestore.firestore().collection(collection).document(id).getDocument()
        guard doc.exists, let data = doc.data() else { return nil }
        return decode(id: id, data: data)
        #else
        return nil
        #endif
    }

    func updateNickname(userID: String, nickname: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        try await Firestore.firestore().collection(collection).document(userID)
            .updateData(["nickname": nickname])
        #endif
    }

    func updateProfileIcon(userID: String, icon: String) async throws {
        #if canImport(FirebaseFirestore)
        guard FirebaseService.shared.isConfigured else { return }
        try await Firestore.firestore().collection(collection).document(userID)
            .updateData(["profileIcon": icon])
        #endif
    }

    // MARK: - Encoding / Decoding

    private func encode(_ user: HaguruUser) -> [String: Any] {
        var data: [String: Any] = [
            "nickname": user.nickname,
            "roleType": user.roleType.rawValue,
            "email": user.email,
            "createdAt": firestoreTimestamp(from: user.createdAt)
        ]
        if let icon = user.profileIcon { data["profileIcon"] = icon }
        if let year = user.birthYear { data["birthYear"] = year }
        return data
    }

    private func decode(id: String, data: [String: Any]) -> HaguruUser {
        let nickname = data["nickname"] as? String ?? ""
        let roleType = UserRole(rawValue: data["roleType"] as? String ?? "") ?? .child
        let email = data["email"] as? String ?? ""
        let profileIcon = data["profileIcon"] as? String
        let birthYear = data["birthYear"] as? Int
        let createdAt = firestoreDate(from: data["createdAt"]) ?? .now

        return HaguruUser(
            id: id,
            nickname: nickname,
            roleType: roleType,
            email: email,
            profileIcon: profileIcon,
            createdAt: createdAt,
            birthYear: birthYear
        )
    }

    // MARK: - Firestore date helpers

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

final class MockUserRepository: UserRepositoryProtocol {
    var users: [String: HaguruUser] = [
        HaguruUser.mockParent.id: .mockParent,
        HaguruUser.mockChild.id: .mockChild,
    ]

    func saveUser(_ user: HaguruUser) async throws { users[user.id] = user }
    func fetchUser(id: String) async throws -> HaguruUser? { users[id] }
    func updateNickname(userID: String, nickname: String) async throws {
        users[userID]?.nickname = nickname
    }
    func updateProfileIcon(userID: String, icon: String) async throws {
        users[userID]?.profileIcon = icon
    }
}
