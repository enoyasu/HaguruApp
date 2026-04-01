import Foundation

enum NotificationType: String, Codable {
    case watered = "watered"
    case cared = "cared"
    case stamped = "stamped"
    case commented = "commented"
    case diaryPosted = "diary_posted"
    case growthLevelUp = "growth_level_up"
    case pairConnected = "pair_connected"

    var sfSymbol: String {
        switch self {
        case .watered: return "drop.fill"
        case .cared: return "hand.raised.fill"
        case .stamped: return "face.smiling.fill"
        case .commented: return "bubble.left.fill"
        case .diaryPosted: return "book.closed.fill"
        case .growthLevelUp: return "sparkles"
        case .pairConnected: return "link.circle.fill"
        }
    }
}

struct NotificationItem: Identifiable, Codable {
    let id: String
    var userID: String
    var type: NotificationType
    var relatedID: String
    var isRead: Bool
    var createdAt: Date
    var message: String
}
