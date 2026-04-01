import SwiftUI

// MARK: - Google Sign-In Button

struct GoogleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: HaguruSpacing.sm) {
                // Google "G" ロゴ（SF Symbols にないので文字で代用）
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 28, height: 28)
                    Text("G")
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "#4285F4"), Color(hex: "#EA4335")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("Google でつづける")
                    .font(HaguruFont.buttonSm())
                    .foregroundColor(Color(hex: "#3C4043"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HaguruSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                    .strokeBorder(Color(hex: "#DADCE0"), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Google でサインイン")
    }
}

// MARK: - OR Divider

struct OrDivider: View {
    var body: some View {
        HStack(spacing: HaguruSpacing.sm) {
            Rectangle()
                .fill(HaguruColors.divider)
                .frame(height: 1)
            Text("または")
                .font(HaguruFont.small())
                .foregroundColor(HaguruColors.textSub)
                .fixedSize()
            Rectangle()
                .fill(HaguruColors.divider)
                .frame(height: 1)
        }
    }
}

// MARK: - Dev Bypass Section（Firebase 未設定時のみ表示）

struct DevBypassSection: View {
    let onDevLogin: () -> Void

    var body: some View {
        VStack(spacing: HaguruSpacing.sm) {
            HStack(spacing: HaguruSpacing.xs) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 12))
                Text("開発モード — Firebase 未設定")
                    .font(HaguruFont.small())
            }
            .foregroundColor(Color.orange.opacity(0.8))

            Button(action: onDevLogin) {
                HStack(spacing: HaguruSpacing.xs) {
                    Image(systemName: "play.circle.fill")
                    Text("テスト用アカウントでスキップ")
                        .font(HaguruFont.captionMedium())
                }
                .foregroundColor(.orange)
                .padding(.horizontal, HaguruSpacing.md)
                .padding(.vertical, HaguruSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                        .fill(Color.orange.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, HaguruSpacing.sm)
    }
}

#Preview {
    VStack(spacing: HaguruSpacing.lg) {
        GoogleSignInButton {}
        OrDivider()
        DevBypassSection {}
    }
    .padding()
    .background(HaguruColors.background)
}
