import SwiftUI

// MARK: - Haguru Brand Colors
// Design Token based color system
// Light/Dark mode adaptive colors

extension Color {
    // MARK: Main Brand Colors
    /// Haguru Leaf Green — メインCTA、選択状態、成長表現
    static let hLeafGreen = Color("HLeafGreen", bundle: nil)

    /// Haguru Petal Pink — スタンプ、リアクション、補助アクセント
    static let hPetalPink = Color("HPetalPink", bundle: nil)

    /// Haguru Sun Amber — バッジ、祝福、特別な瞬間
    static let hSunAmber = Color("HSunAmber", bundle: nil)

    // MARK: Base Colors
    /// 背景色 — メインバックグラウンド
    static let hBackgroundMist = Color("HBackgroundMist", bundle: nil)

    /// カード背景 — カード・シート系
    static let hCardIvory = Color("HCardIvory", bundle: nil)

    /// サーフェス — グリーン系サブ背景
    static let hSurfaceSoftGreen = Color("HSurfaceSoftGreen", bundle: nil)

    /// テキスト — メインテキスト
    static let hTextMain = Color("HTextMain", bundle: nil)

    /// テキスト — サブテキスト
    static let hTextSub = Color("HTextSub", bundle: nil)

    /// 区切り線
    static let hDivider = Color("HDivider", bundle: nil)
}

// MARK: - Fallback inline colors (used when Asset Catalog is not configured)
extension Color {
    static let hLeafGreenFallback = Color(hex: "#5FAF7B")
    static let hPetalPinkFallback = Color(hex: "#F3B7C3")
    static let hSunAmberFallback = Color(hex: "#F3C76A")
    static let hBackgroundMistFallback = Color(hex: "#F8F6F2")
    static let hCardIvoryFallback = Color(hex: "#FFFDF9")
    static let hSurfaceSoftGreenFallback = Color(hex: "#EEF6F0")
    static let hTextMainFallback = Color(hex: "#2E3A32")
    static let hTextSubFallback = Color(hex: "#6E7C73")
    static let hDividerFallback = Color(hex: "#E4E7E2")
}

// MARK: - Hex Color Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Semantic Color Tokens
// Use these throughout the app for consistent theming

struct HaguruColors {
    // Brand
    static var primary: Color { Color.hLeafGreenFallback }
    static var accent: Color { Color.hPetalPinkFallback }
    static var special: Color { Color.hSunAmberFallback }

    // Backgrounds
    static var background: Color { Color.hBackgroundMistFallback }
    static var card: Color { Color.hCardIvoryFallback }
    static var surfaceGreen: Color { Color.hSurfaceSoftGreenFallback }

    // Text
    static var textMain: Color { Color.hTextMainFallback }
    static var textSub: Color { Color.hTextSubFallback }

    // Structure
    static var divider: Color { Color.hDividerFallback }

    // Adaptive
    static var cardShadow: Color { Color.black.opacity(0.06) }

    // Action colors
    static var waterBlue: Color { Color(hex: "#7EC8E3") }
    static var careGreen: Color { Color(hex: "#5FAF7B") }
    static var stampPink: Color { Color(hex: "#F3B7C3") }

    // Dark Mode background (used via environment)
    static var darkBackground: Color { Color(hex: "#1C2420") }
    static var darkCard: Color { Color(hex: "#232E28") }
    static var darkSurface: Color { Color(hex: "#2A3830") }
}
