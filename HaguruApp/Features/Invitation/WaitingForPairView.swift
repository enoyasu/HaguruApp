import SwiftUI

struct WaitingForPairView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String
    let pairLinkID: String

    @State private var pairLink: PairLink?
    @State private var isLoading = true
    @State private var listenerHandle: Any?

    private let pairRepo = PairLinkRepository()

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: HaguruSpacing.xl) {
                    // Animated illustration
                    waitingIllustration
                        .padding(.top, HaguruSpacing.xxl)

                    // Status text
                    VStack(spacing: HaguruSpacing.sm) {
                        Text("相手を待っています")
                            .font(HaguruFont.title2())
                            .foregroundColor(HaguruColors.textMain)

                        Text("下の招待コードを\n相手に伝えましょう")
                            .font(HaguruFont.body())
                            .foregroundColor(HaguruColors.textSub)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    // Invite code card
                    if let code = pairLink?.inviteCode ?? appState.currentPairLink?.inviteCode {
                        InviteCodeCard(code: code)

                        // Share button
                        Button {
                            share(code: code)
                        } label: {
                            Label("コードを共有する", systemImage: "square.and.arrow.up")
                                .font(HaguruFont.captionMedium())
                                .foregroundColor(HaguruColors.primary)
                        }
                        .buttonStyle(.plain)
                    }

                    // Hint
                    SoftCard {
                        VStack(alignment: .leading, spacing: HaguruSpacing.sm) {
                            Label("使い方", systemImage: "info.circle.fill")
                                .font(HaguruFont.captionMedium())
                                .foregroundColor(HaguruColors.primary)

                            VStack(alignment: .leading, spacing: HaguruSpacing.xs) {
                                hintRow("招待コードを相手のスマートフォンに伝える")
                                hintRow("相手が「はぐる」アプリを開いてコードを入力する")
                                hintRow("つながりが確立したら、いっしょに育てられます")
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: HaguruSpacing.xl)
                }
                .padding(.horizontal, HaguruSpacing.lg)
            }

            // Skip / debug option
            VStack(spacing: HaguruSpacing.sm) {
                Divider()
                Button {
                    // For MVP: continue without pair (solo mode placeholder)
                    if let pair = pairLink ?? appState.currentPairLink {
                        appState.continueToMain(pair: pair, growth: appState.currentGrowthObject)
                    }
                } label: {
                    Text("ひとりで先に進む（あとで招待できます）")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                }
                .padding(.bottom, HaguruSpacing.xl)
            }
        }
        .background(HaguruColors.background.ignoresSafeArea())
        .onAppear { startListening() }
        .onDisappear { stopListening() }
    }

    // MARK: - Sub views

    private var waitingIllustration: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(HaguruColors.primary.opacity(0.1 - Double(i) * 0.03), lineWidth: 1)
                    .frame(width: CGFloat(130 + i * 40), height: CGFloat(130 + i * 40))
            }

            Circle()
                .fill(HaguruColors.surfaceGreen)
                .frame(width: 110, height: 110)
                .overlay(
                    Text("🌱")
                        .font(.system(size: 52))
                )
        }
    }

    private func hintRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: HaguruSpacing.xs) {
            Circle()
                .fill(HaguruColors.primary)
                .frame(width: 5, height: 5)
                .padding(.top, 6)

            Text(text)
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Logic

    private func startListening() {
        isLoading = true
        listenerHandle = pairRepo.listenPairLink(for: userID) { [self] updated in
            Task { @MainActor in
                isLoading = false
                pairLink = updated
                if let link = updated, link.isConnected {
                    appState.currentPairLink = link
                    Task { await appState.loadUser(uid: userID) }
                }
            }
        }

        // Also check current pair
        Task {
            if let existing = appState.currentPairLink {
                pairLink = existing
            } else {
                pairLink = try? await pairRepo.fetchPairLink(for: userID)
            }
            isLoading = false
        }
    }

    private func stopListening() {
        listenerHandle = nil
    }

    private func share(code: String) {
        let text = "はぐるで一緒に育てよう！\n招待コード: \(code)\nアプリを開いてコードを入力してください。"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let vc = windowScene.keyWindow?.rootViewController {
            vc.present(av, animated: true)
        }
    }
}

#Preview {
    WaitingForPairView(userID: HaguruUser.mockParent.id, pairLinkID: PairLink.mockPending.id)
        .environmentObject(AppState.shared)
}
