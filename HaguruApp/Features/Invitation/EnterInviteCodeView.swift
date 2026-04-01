import SwiftUI

struct EnterInviteCodeView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String

    @State private var code = ""
    @State private var isLoading = false
    @State private var error: String?
    @FocusState private var isFocused: Bool

    private let pairRepo = PairLinkRepository()
    private let growthRepo = GrowthObjectRepository()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: HaguruSpacing.xl) {
                // Illustration
                VStack(spacing: HaguruSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(HaguruColors.surfaceGreen)
                            .frame(width: 110, height: 110)

                        Text("🔗")
                            .font(.system(size: 52))
                    }

                    VStack(spacing: HaguruSpacing.xs) {
                        Text("招待コードを入力")
                            .font(HaguruFont.title2())
                            .foregroundColor(HaguruColors.textMain)

                        Text("相手から受け取ったコードを入力してください")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)
                            .multilineTextAlignment(.center)
                    }
                }

                // Code input
                VStack(spacing: HaguruSpacing.sm) {
                    TextField("HAGURU-XXXX", text: $code)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(HaguruColors.textMain)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .onChange(of: code) { _, new in
                            code = new.uppercased()
                        }
                        .padding(HaguruSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                .fill(HaguruColors.card)
                                .shadow(color: HaguruColors.cardShadow, radius: 8, x: 0, y: 3)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                .strokeBorder(
                                    isFocused ? HaguruColors.primary.opacity(0.4) : Color.clear,
                                    lineWidth: 1.5
                                )
                        )

                    if let error {
                        HaguruErrorBanner(message: error) { self.error = nil }
                    }
                }

                // CTA
                PrimaryButton(
                    title: "つながる",
                    icon: "link",
                    isLoading: isLoading,
                    isDisabled: code.trimmingCharacters(in: .whitespaces).isEmpty
                ) {
                    Task { await connect() }
                }
            }
            .padding(.horizontal, HaguruSpacing.lg)

            Spacer()

            // Skip
            TextLinkButton(title: "あとで入力する") {
                // Navigate to a basic home / waiting state
                appState.screen = .main
            }
            .padding(.bottom, HaguruSpacing.xl)
        }
        .background(HaguruColors.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }

    private func connect() async {
        let trimmed = code.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            guard let pair = try await pairRepo.fetchPairLink(byCode: trimmed) else {
                error = "コードが見つかりません。もう一度確認してください。"
                return
            }

            try await pairRepo.connectPair(pairLinkID: pair.id, childUserID: userID)

            let connectedPair = PairLink(
                id: pair.id,
                parentUserID: pair.parentUserID,
                childUserID: userID,
                relationshipType: pair.relationshipType,
                inviteCode: pair.inviteCode,
                inviteStatus: .connected,
                createdAt: pair.createdAt
            )
            appState.currentPairLink = connectedPair

            let growth = try await growthRepo.fetchGrowthObject(for: pair.id)
            appState.continueToMain(pair: connectedPair, growth: growth)
        } catch {
            self.error = "接続に失敗しました。もう一度お試しください。"
        }
    }
}

#Preview {
    EnterInviteCodeView(userID: HaguruUser.mockChild.id)
        .environmentObject(AppState.shared)
}
