import Foundation

enum ActionType: String, Codable, CaseIterable {
    case water = "water"
    case care = "care"
    case stamp = "stamp"
    case comment = "comment"
    case diary = "diary"

    var displayName: String {
        switch self {
        case .water: return "水やり"
        case .care: return "お世話"
        case .stamp: return "スタンプ"
        case .comment: return "ひとこと"
        case .diary: return "日記"
        }
    }

    var sfSymbol: String {
        switch self {
        case .water: return "drop.fill"
        case .care: return "hand.raised.fill"
        case .stamp: return "face.smiling.fill"
        case .comment: return "bubble.left.fill"
        case .diary: return "book.closed.fill"
        }
    }

    var pointValue: Int {
        switch self {
        case .water: return 3
        case .care: return 5
        case .stamp: return 1
        case .comment: return 2
        case .diary: return 4
        }
    }

    var feedMessage: String {
        switch self {
        case .water: return "水やりをしました"
        case .care: return "お世話をしました"
        case .stamp: return "スタンプを送りました"
        case .comment: return "ひとこと残しました"
        case .diary: return "日記を書きました"
        }
    }
}

enum StampType: String, Codable, CaseIterable {
    case heart = "heart"
    case flower = "flower"
    case sun = "sun"
    case star = "star"
    case wave = "wave"
    case clap = "clap"
    case seedling = "seedling"
    case rainbow = "rainbow"

    var emoji: String {
        switch self {
        case .heart: return "❤️"
        case .flower: return "🌸"
        case .sun: return "☀️"
        case .star: return "⭐️"
        case .wave: return "👋"
        case .clap: return "👏"
        case .seedling: return "🌱"
        case .rainbow: return "🌈"
        }
    }

    var label: String {
        switch self {
        case .heart: return "いいね"
        case .flower: return "きれい"
        case .sun: return "げんき"
        case .star: return "すごい"
        case .wave: return "やあ"
        case .clap: return "えらい"
        case .seedling: return "のびのび"
        case .rainbow: return "いろいろ"
        }
    }
}

struct ActivityLog: Identifiable, Codable {
    let id: String
    var growthObjectID: String
    var actorUserID: String
    var actorNickname: String
    var actionType: ActionType
    var text: String?
    var stampType: StampType?
    var imageURL: String?
    var createdAt: Date
}

// MARK: - Mock
extension ActivityLog {
    static let mockLogs: [ActivityLog] = [
        ActivityLog(
            id: "log-001",
            growthObjectID: GrowthObject.mockFlower.id,
            actorUserID: HaguruUser.mockParent.id,
            actorNickname: "お母さん",
            actionType: .water,
            text: nil,
            stampType: nil,
            createdAt: Calendar.current.date(byAdding: .hour, value: -1, to: .now)!
        ),
        ActivityLog(
            id: "log-002",
            growthObjectID: GrowthObject.mockFlower.id,
            actorUserID: HaguruUser.mockChild.id,
            actorNickname: "はなちゃん",
            actionType: .stamp,
            text: nil,
            stampType: .heart,
            createdAt: Calendar.current.date(byAdding: .hour, value: -3, to: .now)!
        ),
        ActivityLog(
            id: "log-003",
            growthObjectID: GrowthObject.mockFlower.id,
            actorUserID: HaguruUser.mockChild.id,
            actorNickname: "はなちゃん",
            actionType: .comment,
            text: "今日はいい天気だよ〜",
            stampType: nil,
            createdAt: Calendar.current.date(byAdding: .hour, value: -5, to: .now)!
        ),
        ActivityLog(
            id: "log-004",
            growthObjectID: GrowthObject.mockFlower.id,
            actorUserID: HaguruUser.mockParent.id,
            actorNickname: "お母さん",
            actionType: .care,
            text: "よく育ってきたね",
            stampType: nil,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        ),
        ActivityLog(
            id: "log-005",
            growthObjectID: GrowthObject.mockFlower.id,
            actorUserID: HaguruUser.mockChild.id,
            actorNickname: "はなちゃん",
            actionType: .diary,
            text: "テストが終わってほっとした。また明日から頑張ろう。",
            stampType: nil,
            createdAt: Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        ),
    ]
}
