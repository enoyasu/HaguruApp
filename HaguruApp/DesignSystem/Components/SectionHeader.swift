import SwiftUI

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil
    var action: (title: String, handler: () -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HaguruFont.title3())
                    .foregroundColor(HaguruColors.textMain)

                if let subtitle {
                    Text(subtitle)
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                }
            }

            Spacer()

            if let action {
                Button(action: action.handler) {
                    Text(action.title)
                        .font(HaguruFont.captionMedium())
                        .foregroundColor(HaguruColors.primary)
                }
            }
        }
    }
}

struct HaguruBrandHeader: View {
    var subtitle: String? = nil
    var size: Size = .regular

    enum Size {
        case compact, regular, large
        var fontSize: CGFloat {
            switch self {
            case .compact: return 22
            case .regular: return 32
            case .large: return 44
            }
        }
    }

    var body: some View {
        VStack(spacing: HaguruSpacing.xs) {
            Text("はぐる")
                .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [HaguruColors.primary, HaguruColors.primary.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .accessibilityLabel("はぐる")

            if let subtitle {
                Text(subtitle)
                    .font(HaguruFont.caption())
                    .foregroundColor(HaguruColors.textSub)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    VStack(spacing: HaguruSpacing.xl) {
        HaguruBrandHeader(subtitle: "やさしくつながる共育アプリ", size: .large)

        SectionHeader(
            title: "今日の記録",
            subtitle: "みんなの動きが見えます",
            action: ("もっと見る", {})
        )
        .padding(.horizontal)

        SectionHeader(title: "つながり")
            .padding(.horizontal)
    }
    .padding()
    .background(HaguruColors.background)
}
