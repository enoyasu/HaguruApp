import Foundation

enum RelationshipType: String, Codable, CaseIterable {
    case motherDaughter = "mother_daughter"
    case fatherSon = "father_son"
    case motherSon = "mother_son"
    case fatherDaughter = "father_daughter"
    case guardianChild = "guardian_child"
    case other = "other"

    var displayName: String {
        switch self {
        case .motherDaughter: return "母×娘"
        case .fatherSon: return "父×息子"
        case .motherSon: return "母×息子"
        case .fatherDaughter: return "父×娘"
        case .guardianChild: return "保護者×子"
        case .other: return "その他"
        }
    }

    var emoji: String {
        switch self {
        case .motherDaughter: return "💐"
        case .fatherSon: return "⚽️"
        case .motherSon: return "🌿"
        case .fatherDaughter: return "🌸"
        case .guardianChild: return "🤝"
        case .other: return "✨"
        }
    }

    var description: String {
        switch self {
        case .motherDaughter: return "お母さんと娘さんで"
        case .fatherSon: return "お父さんと息子さんで"
        case .motherSon: return "お母さんと息子さんで"
        case .fatherDaughter: return "お父さんと娘さんで"
        case .guardianChild: return "保護者と子で"
        case .other: return "ふたりで"
        }
    }
}

enum InviteStatus: String, Codable {
    case pending = "pending"
    case connected = "connected"
    case cancelled = "cancelled"
}

struct PairLink: Identifiable, Codable, Equatable {
    let id: String
    var parentUserID: String
    var childUserID: String?
    var relationshipType: RelationshipType
    var inviteCode: String
    var inviteStatus: InviteStatus
    var createdAt: Date

    var isConnected: Bool { inviteStatus == .connected }
}

// MARK: - Mock
extension PairLink {
    static let mockConnected = PairLink(
        id: "mock-pair-001",
        parentUserID: HaguruUser.mockParent.id,
        childUserID: HaguruUser.mockChild.id,
        relationshipType: .motherDaughter,
        inviteCode: "HAGURU-ABCD",
        inviteStatus: .connected,
        createdAt: Calendar.current.date(byAdding: .day, value: -30, to: .now)!
    )
    static let mockPending = PairLink(
        id: "mock-pair-002",
        parentUserID: HaguruUser.mockParent.id,
        childUserID: nil,
        relationshipType: .motherDaughter,
        inviteCode: "HAGURU-XYZW",
        inviteStatus: .pending,
        createdAt: .now
    )
}
