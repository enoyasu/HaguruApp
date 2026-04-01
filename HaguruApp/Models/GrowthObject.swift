import Foundation

enum GrowthObjectType: String, Codable, CaseIterable {
    case flower = "flower"
    case tree = "tree"
    case spirit = "spirit"

    var displayName: String {
        switch self {
        case .flower: return "お花"
        case .tree: return "大きな木"
        case .spirit: return "ふしぎな精霊"
        }
    }

    var emoji: String {
        switch self {
        case .flower: return "🌸"
        case .tree: return "🌳"
        case .spirit: return "✨"
        }
    }

    var description: String {
        switch self {
        case .flower: return "ふたりで水やりをして、きれいな花を咲かせよう"
        case .tree: return "長い時間をかけて、大きな木に育てよう"
        case .spirit: return "ふしぎな精霊を、ふたりでゆっくり育てよう"
        }
    }

    var growthEmojis: [GrowthState: String] {
        switch self {
        case .flower:
            return [.seed: "🌱", .sprout: "🪴", .growing: "🌿", .blooming: "🌸", .flourishing: "🌺"]
        case .tree:
            return [.seed: "🌱", .sprout: "🌿", .growing: "🌲", .blooming: "🌳", .flourishing: "🎋"]
        case .spirit:
            return [.seed: "🌑", .sprout: "🌒", .growing: "🌓", .blooming: "🌕", .flourishing: "⭐️"]
        }
    }

    func emoji(for state: GrowthState) -> String {
        growthEmojis[state] ?? emoji
    }
}

enum GrowthState: String, Codable, CaseIterable {
    case seed = "seed"
    case sprout = "sprout"
    case growing = "growing"
    case blooming = "blooming"
    case flourishing = "flourishing"

    var displayName: String {
        switch self {
        case .seed: return "たね"
        case .sprout: return "めばえ"
        case .growing: return "すくすく"
        case .blooming: return "さかり"
        case .flourishing: return "みのり"
        }
    }

    var message: String {
        switch self {
        case .seed: return "ふたりの育てがはじまりました"
        case .sprout: return "小さな芽が出てきました"
        case .growing: return "すくすくと育っています"
        case .blooming: return "とてもきれいに育っています"
        case .flourishing: return "ふたりの愛情でいっぱいです"
        }
    }

    var pointThreshold: Int {
        switch self {
        case .seed: return 0
        case .sprout: return 10
        case .growing: return 30
        case .blooming: return 70
        case .flourishing: return 120
        }
    }

    static func state(for points: Int) -> GrowthState {
        if points >= GrowthState.flourishing.pointThreshold { return .flourishing }
        if points >= GrowthState.blooming.pointThreshold { return .blooming }
        if points >= GrowthState.growing.pointThreshold { return .growing }
        if points >= GrowthState.sprout.pointThreshold { return .sprout }
        return .seed
    }
}

struct GrowthObject: Identifiable, Codable, Equatable {
    let id: String
    var pairLinkID: String
    var type: GrowthObjectType
    var name: String
    var growthPoints: Int
    var lastActionAt: Date?

    var currentState: GrowthState {
        GrowthState.state(for: growthPoints)
    }

    var level: Int {
        max(1, growthPoints / 10 + 1)
    }

    var nextStatePoints: Int {
        switch currentState {
        case .seed: return GrowthState.sprout.pointThreshold
        case .sprout: return GrowthState.growing.pointThreshold
        case .growing: return GrowthState.blooming.pointThreshold
        case .blooming: return GrowthState.flourishing.pointThreshold
        case .flourishing: return GrowthState.flourishing.pointThreshold
        }
    }

    var progressToNextState: Double {
        guard currentState != .flourishing else { return 1.0 }
        let start = Double(currentState.pointThreshold)
        let end = Double(nextStatePoints)
        guard end > start else { return 1.0 }
        return min(1.0, (Double(growthPoints) - start) / (end - start))
    }

    var currentEmoji: String {
        type.emoji(for: currentState)
    }
}

// MARK: - Mock
extension GrowthObject {
    static let mockFlower = GrowthObject(
        id: "mock-growth-001",
        pairLinkID: PairLink.mockConnected.id,
        type: .flower,
        name: "はなちゃんのお花",
        growthPoints: 35,
        lastActionAt: Calendar.current.date(byAdding: .hour, value: -3, to: .now)
    )
}
