import SwiftUI

// MARK: - Design Tokens
// Single source of truth for spacing, radius, typography, animation

enum HaguruSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum HaguruRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 14
    static let lg: CGFloat = 20
    static let xl: CGFloat = 28
    static let full: CGFloat = 100
}

enum HaguruShadow {
    static let soft = ShadowStyle(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    static let card = ShadowStyle(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 6)
    static let button = ShadowStyle(color: HaguruColors.primary.opacity(0.3), radius: 12, x: 0, y: 6)

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

enum HaguruFont {
    static func brandTitle() -> Font { .system(size: 34, weight: .bold, design: .rounded) }
    static func title1() -> Font { .system(size: 28, weight: .bold, design: .rounded) }
    static func title2() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func title3() -> Font { .system(size: 18, weight: .semibold, design: .rounded) }
    static func body() -> Font { .system(size: 16, weight: .regular, design: .default) }
    static func bodyMedium() -> Font { .system(size: 16, weight: .medium, design: .default) }
    static func caption() -> Font { .system(size: 14, weight: .regular, design: .default) }
    static func captionMedium() -> Font { .system(size: 14, weight: .medium, design: .default) }
    static func small() -> Font { .system(size: 12, weight: .regular, design: .default) }
    static func smallMedium() -> Font { .system(size: 12, weight: .medium, design: .default) }
    static func button() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func buttonSm() -> Font { .system(size: 15, weight: .semibold, design: .rounded) }
}

enum HaguruAnimation {
    static let spring = Animation.spring(response: 0.45, dampingFraction: 0.7)
    static let springFast = Animation.spring(response: 0.3, dampingFraction: 0.75)
    static let easeOut = Animation.easeOut(duration: 0.25)
    static let easeIn = Animation.easeIn(duration: 0.2)
    static let gentle = Animation.easeInOut(duration: 0.35)
}

// MARK: - View Modifiers

struct HaguruCardModifier: ViewModifier {
    var padding: CGFloat = HaguruSpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(HaguruColors.card)
            .clipShape(RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous))
            .shadow(
                color: HaguruShadow.soft.color,
                radius: HaguruShadow.soft.radius,
                x: HaguruShadow.soft.x,
                y: HaguruShadow.soft.y
            )
    }
}

struct HaguruPrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HaguruFont.button())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.full, style: .continuous)
                    .fill(HaguruColors.primary)
                    .shadow(
                        color: HaguruColors.primary.opacity(0.35),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(isLoading ? 0.7 : 1.0)
            .animation(HaguruAnimation.springFast, value: configuration.isPressed)
    }
}

struct HaguruSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HaguruFont.button())
            .foregroundColor(HaguruColors.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.full, style: .continuous)
                    .strokeBorder(HaguruColors.primary, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: HaguruRadius.full, style: .continuous)
                            .fill(HaguruColors.primary.opacity(0.06))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(HaguruAnimation.springFast, value: configuration.isPressed)
    }
}

extension View {
    func haguruCard(padding: CGFloat = HaguruSpacing.md) -> some View {
        modifier(HaguruCardModifier(padding: padding))
    }
}
