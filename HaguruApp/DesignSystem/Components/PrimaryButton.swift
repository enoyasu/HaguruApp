import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HaguruSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                    }
                    Text(title)
                }
            }
        }
        .buttonStyle(HaguruPrimaryButtonStyle(isLoading: isLoading))
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
        .accessibilityLabel(title)
    }
}

struct SecondaryButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HaguruSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
                Text(title)
            }
        }
        .buttonStyle(HaguruSecondaryButtonStyle())
        .accessibilityLabel(title)
    }
}

struct TextLinkButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.primary)
                .underline()
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Action Button (Home screen circular actions)
struct ActionCircleButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: HaguruSpacing.xxs) {
                Circle()
                    .fill(color.opacity(0.15))
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(color)
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)

                Text(title)
                    .font(HaguruFont.small())
                    .foregroundColor(HaguruColors.textSub)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: HaguruSpacing.md) {
        PrimaryButton(title: "水やりをする", icon: "drop.fill") {}
        PrimaryButton(title: "読み込み中", isLoading: true) {}
        SecondaryButton(title: "スキップする") {}
        TextLinkButton(title: "すでにアカウントをお持ちの方") {}
        HStack {
            ActionCircleButton(title: "水やり", icon: "drop.fill", color: HaguruColors.waterBlue) {}
            ActionCircleButton(title: "お世話", icon: "hand.raised.fill", color: HaguruColors.careGreen) {}
            ActionCircleButton(title: "ひとこと", icon: "bubble.left.fill", color: HaguruColors.accent) {}
        }
    }
    .padding()
    .background(HaguruColors.background)
}
