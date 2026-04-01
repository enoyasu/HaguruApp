import SwiftUI

struct GrowthObjectSelectionView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String
    let pairLinkID: String

    @State private var selectedType: GrowthObjectType?
    @State private var name = ""
    @State private var isLoading = false
    @State private var error: String?
    @FocusState private var nameFocused: Bool

    private let growthRepo = GrowthObjectRepository()
    private let maxLength = 12

    var body: some View {
        ScrollView {
            VStack(spacing: HaguruSpacing.xl) {
                // Header
                VStack(spacing: HaguruSpacing.md) {
                    Text("何を育てますか？")
                        .font(HaguruFont.title2())
                        .foregroundColor(HaguruColors.textMain)
                        .padding(.top, HaguruSpacing.xl)

                    Text("ふたりで育てる対象を選んでください")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                }

                // Object cards
                VStack(spacing: HaguruSpacing.md) {
                    ForEach(GrowthObjectType.allCases, id: \.self) { type in
                        objectCard(type)
                    }
                }

                // Name input (shown after selection)
                if selectedType != nil {
                    VStack(alignment: .leading, spacing: HaguruSpacing.xs) {
                        Text("なまえをつける（任意）")
                            .font(HaguruFont.captionMedium())
                            .foregroundColor(HaguruColors.textSub)

                        HStack {
                            TextField("例: はなちゃんのお花", text: $name)
                                .focused($nameFocused)
                                .font(HaguruFont.body())
                                .foregroundColor(HaguruColors.textMain)
                                .onChange(of: name) { _, new in
                                    if new.count > maxLength { name = String(new.prefix(maxLength)) }
                                }

                            Text("\(name.count)/\(maxLength)")
                                .font(HaguruFont.small())
                                .foregroundColor(HaguruColors.textSub)
                        }
                        .padding(HaguruSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                .fill(HaguruColors.card)
                                .shadow(color: HaguruColors.cardShadow, radius: 6, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                .strokeBorder(
                                    nameFocused ? HaguruColors.primary.opacity(0.4) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let error {
                    HaguruErrorBanner(message: error) { self.error = nil }
                }

                // Spacer for keyboard
                Spacer(minLength: 120)
            }
            .padding(.horizontal, HaguruSpacing.lg)
        }
        .background(HaguruColors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(
                title: "育てはじめる",
                icon: "leaf.fill",
                isLoading: isLoading,
                isDisabled: selectedType == nil
            ) {
                Task { await createGrowthObject() }
            }
            .padding(HaguruSpacing.lg)
            .background(
                HaguruColors.card
                    .shadow(color: HaguruColors.cardShadow, radius: 12, x: 0, y: -4)
                    .ignoresSafeArea()
            )
        }
        .animation(HaguruAnimation.spring, value: selectedType)
    }

    private func objectCard(_ type: GrowthObjectType) -> some View {
        let isSelected = selectedType == type

        return Button {
            withAnimation(HaguruAnimation.spring) { selectedType = type }
        } label: {
            HStack(spacing: HaguruSpacing.md) {
                ZStack {
                    Circle()
                        .fill(isSelected ? HaguruColors.primary.opacity(0.15) : HaguruColors.surfaceGreen)
                        .frame(width: 60, height: 60)

                    Text(type.emoji)
                        .font(.system(size: 32))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(type.displayName)
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)

                    Text(type.description)
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? HaguruColors.primary : HaguruColors.divider)
            }
            .padding(HaguruSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .fill(HaguruColors.card)
                    .shadow(
                        color: isSelected ? HaguruColors.primary.opacity(0.15) : HaguruColors.cardShadow,
                        radius: isSelected ? 14 : 6,
                        x: 0, y: isSelected ? 6 : 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: HaguruRadius.lg, style: .continuous)
                    .strokeBorder(
                        isSelected ? HaguruColors.primary.opacity(0.35) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(HaguruAnimation.spring, value: isSelected)
        .accessibilityLabel(type.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func createGrowthObject() async {
        guard let type = selectedType else { return }
        isLoading = true
        defer { isLoading = false }

        let defaultName = name.isEmpty
            ? (appState.currentUser.map { "\($0.nickname)の\(type.displayName)" } ?? type.displayName)
            : name

        let growth = GrowthObject(
            id: UUID().uuidString,
            pairLinkID: pairLinkID,
            type: type,
            name: defaultName,
            growthPoints: 0
        )

        do {
            try await growthRepo.createGrowthObject(growth)
            let pair = appState.currentPairLink ?? PairLink(
                id: pairLinkID,
                parentUserID: userID,
                childUserID: nil,
                relationshipType: .other,
                inviteCode: InviteCodeGenerator.generate(),
                inviteStatus: .pending,
                createdAt: .now
            )
            appState.continueToMain(pair: pair, growth: growth)
            // 招待コードを見せる
            appState.screen = .waitingForPair(userID: userID, pairLinkID: pairLinkID)
        } catch {
            self.error = "エラーが発生しました。もう一度お試しください。"
        }
    }
}

#Preview {
    GrowthObjectSelectionView(userID: "preview-uid", pairLinkID: "preview-pair")
        .environmentObject(AppState.shared)
}
