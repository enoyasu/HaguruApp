import SwiftUI

struct RelationshipSelectionView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String

    @State private var selected: RelationshipType?
    @State private var isLoading = false
    @State private var error: String?

    private let pairRepo = PairLinkRepository()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HaguruSpacing.xl) {
                    // Header
                    VStack(spacing: HaguruSpacing.md) {
                        Text("💞")
                            .font(.system(size: 56))
                            .padding(.top, HaguruSpacing.xl)

                        VStack(spacing: HaguruSpacing.xs) {
                            Text("どんな関係ですか？")
                                .font(HaguruFont.title2())
                                .foregroundColor(HaguruColors.textMain)

                            Text("育てる相手との関係性を選んでください")
                                .font(HaguruFont.caption())
                                .foregroundColor(HaguruColors.textSub)
                                .multilineTextAlignment(.center)
                        }
                    }

                    // Relationship grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: HaguruSpacing.sm), count: 2),
                        spacing: HaguruSpacing.sm
                    ) {
                        ForEach(RelationshipType.allCases, id: \.self) { type in
                            relationshipCard(type)
                        }
                    }

                    if let error {
                        HaguruErrorBanner(message: error) { self.error = nil }
                    }
                }
                .padding(.horizontal, HaguruSpacing.lg)
                .padding(.bottom, HaguruSpacing.xxl + 80)
            }

            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                    .foregroundColor(HaguruColors.divider)

                PrimaryButton(
                    title: "招待コードを発行する",
                    icon: "person.badge.plus",
                    isLoading: isLoading,
                    isDisabled: selected == nil
                ) {
                    Task { await createPairLink() }
                }
                .padding(HaguruSpacing.lg)
            }
            .background(HaguruColors.card)
        }
        .background(HaguruColors.background.ignoresSafeArea())
    }

    private func relationshipCard(_ type: RelationshipType) -> some View {
        let isSelected = selected == type

        return Button {
            withAnimation(HaguruAnimation.spring) { selected = type }
        } label: {
            VStack(spacing: HaguruSpacing.sm) {
                Text(type.emoji)
                    .font(.system(size: 36))

                VStack(spacing: 2) {
                    Text(type.displayName)
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)

                    Text(type.description)
                        .font(HaguruFont.small())
                        .foregroundColor(HaguruColors.textSub)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HaguruSpacing.md)
            .padding(.horizontal, HaguruSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .fill(isSelected ? HaguruColors.primary.opacity(0.1) : HaguruColors.card)
                    .shadow(
                        color: isSelected ? HaguruColors.primary.opacity(0.2) : HaguruColors.cardShadow,
                        radius: isSelected ? 12 : 6,
                        x: 0, y: isSelected ? 6 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .strokeBorder(
                        isSelected ? HaguruColors.primary.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(HaguruAnimation.spring, value: isSelected)
        .accessibilityLabel(type.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func createPairLink() async {
        guard let relationship = selected else { return }
        isLoading = true
        defer { isLoading = false }

        let pairLink = PairLink(
            id: UUID().uuidString,
            parentUserID: userID, // child側が作成、招待コードで親を迎える設計
            childUserID: userID,
            relationshipType: relationship,
            inviteCode: InviteCodeGenerator.generate(),
            inviteStatus: .pending,
            createdAt: .now
        )

        do {
            try await pairRepo.createPairLink(pairLink)
            appState.currentPairLink = pairLink
            appState.screen = .growthObjectSelection(userID: userID, pairLinkID: pairLink.id)
        } catch {
            self.error = "エラーが発生しました。もう一度お試しください。"
        }
    }
}

#Preview {
    RelationshipSelectionView(userID: "preview-uid")
        .environmentObject(AppState.shared)
}
