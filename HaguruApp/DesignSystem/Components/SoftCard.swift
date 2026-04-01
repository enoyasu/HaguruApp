import SwiftUI

struct SoftCard<Content: View>: View {
    var padding: CGFloat
    @ViewBuilder let content: () -> Content

    init(padding: CGFloat = HaguruSpacing.md, @ViewBuilder content: @escaping () -> Content) {
        self.padding = padding
        self.content = content
    }

    var body: some View {
        content()
            .padding(padding)
            .background(HaguruColors.card)
            .clipShape(RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous))
            .shadow(color: HaguruColors.cardShadow, radius: 12, x: 0, y: 4)
    }
}

struct GrowthStatusCard: View {
    let growthObject: GrowthObject
    let partnerNickname: String?

    var body: some View {
        VStack(spacing: HaguruSpacing.md) {
            // Growth visualization
            ZStack {
                Circle()
                    .fill(HaguruColors.surfaceGreen)
                    .frame(width: 140, height: 140)

                Text(growthObject.currentEmoji)
                    .font(.system(size: 72))
            }

            // State info
            VStack(spacing: HaguruSpacing.xxs) {
                Text(growthObject.name)
                    .font(HaguruFont.title3())
                    .foregroundColor(HaguruColors.textMain)

                Text(growthObject.currentState.displayName)
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(HaguruColors.primary)
                    .padding(.horizontal, HaguruSpacing.sm)
                    .padding(.vertical, HaguruSpacing.xxs)
                    .background(
                        Capsule()
                            .fill(HaguruColors.primary.opacity(0.12))
                    )
            }

            // Growth bar
            VStack(alignment: .leading, spacing: HaguruSpacing.xxs) {
                HStack {
                    Text(growthObject.currentState.displayName)
                        .font(HaguruFont.small())
                        .foregroundColor(HaguruColors.textSub)
                    Spacer()
                    Text(nextStateLabel)
                        .font(HaguruFont.small())
                        .foregroundColor(HaguruColors.textSub)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(HaguruColors.divider)
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [HaguruColors.primary, HaguruColors.primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * growthObject.progressToNextState,
                                height: 6
                            )
                            .animation(HaguruAnimation.gentle, value: growthObject.progressToNextState)
                    }
                }
                .frame(height: 6)

                Text(growthObject.currentState.message)
                    .font(HaguruFont.caption())
                    .foregroundColor(HaguruColors.textSub)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HaguruSpacing.lg)
        .background(HaguruColors.card)
        .clipShape(RoundedRectangle(cornerRadius: HaguruRadius.xl, style: .continuous))
        .shadow(color: HaguruColors.cardShadow, radius: 16, x: 0, y: 6)
    }

    private var nextStateLabel: String {
        guard growthObject.currentState != .flourishing else { return "みのり ✨" }
        let next: GrowthState
        switch growthObject.currentState {
        case .seed: next = .sprout
        case .sprout: next = .growing
        case .growing: next = .blooming
        case .blooming: next = .flourishing
        case .flourishing: return ""
        }
        return next.displayName
    }
}

#Preview {
    VStack(spacing: HaguruSpacing.md) {
        GrowthStatusCard(growthObject: .mockFlower, partnerNickname: "お母さん")

        SoftCard {
            VStack {
                Text("SoftCard content")
                Text("やさしいカード")
            }
        }
    }
    .padding()
    .background(HaguruColors.background)
}
