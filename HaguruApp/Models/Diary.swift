import Foundation

enum MoodType: String, Codable, CaseIterable {
    case happy = "happy"
    case calm = "calm"
    case tired = "tired"
    case excited = "excited"
    case grateful = "grateful"
    case lonely = "lonely"

    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .calm: return "😌"
        case .tired: return "😴"
        case .excited: return "🎉"
        case .grateful: return "🙏"
        case .lonely: return "🌙"
        }
    }

    var label: String {
        switch self {
        case .happy: return "うれしい"
        case .calm: return "おだやか"
        case .tired: return "つかれた"
        case .excited: return "わくわく"
        case .grateful: return "ありがとう"
        case .lonely: return "さみしい"
        }
    }
}

struct Diary: Identifiable, Codable {
    let id: String
    var pairLinkID: String
    var authorUserID: String
    var authorNickname: String
    var title: String
    var body: String
    var mood: MoodType?
    var createdAt: Date
}

// MARK: - Mock
extension Diary {
    static let mockDiaries: [Diary] = [
        Diary(
            id: "diary-001",
            pairLinkID: PairLink.mockConnected.id,
            authorUserID: HaguruUser.mockChild.id,
            authorNickname: "はなちゃん",
            title: "部活の帰り道",
            body: "今日は練習が長くてくたくただったけど、夕焼けがきれいで少し元気が出た。",
            mood: .calm,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now)!
        ),
        Diary(
            id: "diary-002",
            pairLinkID: PairLink.mockConnected.id,
            authorUserID: HaguruUser.mockParent.id,
            authorNickname: "お母さん",
            title: "今日のお花",
            body: "お花がまた少し育ったみたい。ふたりで育てているから特別な気がするよ。",
            mood: .happy,
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now)!
        ),
    ]
}
