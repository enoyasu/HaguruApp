import Foundation

enum UserRole: String, Codable, CaseIterable {
    case parent = "parent"
    case child = "child"

    var displayName: String {
        switch self {
        case .parent: return "親として始める"
        case .child: return "子として始める"
        }
    }

    var description: String {
        switch self {
        case .parent: return "お子さまを招待して、いっしょに育てましょう"
        case .child: return "親御さんを招待して、いっしょに育てましょう"
        }
    }

    var icon: String {
        switch self {
        case .parent: return "person.2.fill"
        case .child: return "person.fill"
        }
    }
}

struct HaguruUser: Identifiable, Codable, Equatable {
    let id: String
    var nickname: String
    var roleType: UserRole
    var email: String
    var profileIcon: String?
    var createdAt: Date
    var birthYear: Int?

    init(
        id: String,
        nickname: String,
        roleType: UserRole,
        email: String,
        profileIcon: String? = nil,
        createdAt: Date = .now,
        birthYear: Int? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.roleType = roleType
        self.email = email
        self.profileIcon = profileIcon
        self.createdAt = createdAt
        self.birthYear = birthYear
    }
}

// MARK: - Mock
extension HaguruUser {
    static let mockParent = HaguruUser(
        id: "mock-parent-001",
        nickname: "お母さん",
        roleType: .parent,
        email: "parent@example.com"
    )
    static let mockChild = HaguruUser(
        id: "mock-child-001",
        nickname: "はなちゃん",
        roleType: .child,
        email: "child@example.com"
    )
}
