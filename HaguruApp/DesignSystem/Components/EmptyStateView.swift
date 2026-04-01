import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: HaguruSpacing.lg) {
            Spacer()

            VStack(spacing: HaguruSpacing.md) {
                ZStack {
                    Circle()
                        .fill(HaguruColors.surfaceGreen)
                        .frame(width: 100, height: 100)

                    Image(systemName: icon)
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(HaguruColors.primary)
                }

                VStack(spacing: HaguruSpacing.xs) {
                    Text(title)
                        .font(HaguruFont.title3())
                        .foregroundColor(HaguruColors.textMain)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(HaguruFont.body())
                        .foregroundColor(HaguruColors.textSub)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(maxWidth: 240)
            }

            Spacer()
        }
        .padding(.horizontal, HaguruSpacing.xl)
    }
}

// MARK: - Loading Overlay
struct HaguruLoadingView: View {
    var message: String = "読み込み中..."

    var body: some View {
        VStack(spacing: HaguruSpacing.md) {
            ProgressView()
                .tint(HaguruColors.primary)
                .scaleEffect(1.2)

            Text(message)
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(HaguruColors.background.opacity(0.85))
    }
}

// MARK: - Error Banner
struct HaguruErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: HaguruSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(.red.opacity(0.8))

            Text(message)
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textMain)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(HaguruColors.textSub)
                }
            }
        }
        .padding(HaguruSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                        .strokeBorder(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack {
        EmptyStateView(
            icon: "leaf",
            title: "まだ記録がありません",
            message: "水やりやひとことを残すと\nここに表示されます",
            actionTitle: "水やりをする",
            action: {}
        )

        HaguruErrorBanner(message: "エラーが発生しました。もう一度お試しください。") {}
            .padding()
    }
    .background(HaguruColors.background)
}
