import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = ConnectionViewModel()
    @State private var showInviteSheet = false
    @State private var showEnterCodeSheet = false
    @State private var showDisconnectAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HaguruSpacing.lg) {
                    if let pair = appState.currentPairLink {
                        if pair.isConnected {
                            connectedView(pair)
                        } else {
                            pendingView(pair)
                        }
                    } else {
                        noConnectionView
                    }

                    // Notification settings hint
                    notificationSection

                    Spacer(minLength: HaguruSpacing.xl)
                }
                .padding(.horizontal, HaguruSpacing.md)
                .padding(.top, HaguruSpacing.sm)
                .padding(.bottom, HaguruSpacing.xxl)
            }
            .background(HaguruColors.background.ignoresSafeArea())
            .navigationTitle("つながり")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showInviteSheet) {
            if let code = appState.currentPairLink?.inviteCode {
                inviteSheet(code: code)
            }
        }
        .sheet(isPresented: $showEnterCodeSheet) {
            EnterInviteCodeView(userID: appState.currentUser?.id ?? "")
                .environmentObject(appState)
        }
        .alert("連携を解除しますか？", isPresented: $showDisconnectAlert) {
            Button("解除する", role: .destructive) { /* MVP: stub */ }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("育てているものは残りますが、相手との連携が切れます。")
        }
        .task {
            if let pair = appState.currentPairLink,
               let userID = appState.currentUser?.id {
                await vm.loadPartner(pairLink: pair, currentUserID: userID)
            }
        }
    }

    // MARK: - Connected View

    private func connectedView(_ pair: PairLink) -> some View {
        VStack(spacing: HaguruSpacing.md) {
            SoftCard {
                VStack(spacing: HaguruSpacing.md) {
                    HStack(spacing: HaguruSpacing.md) {
                        // Partner avatar
                        ZStack {
                            Circle()
                                .fill(HaguruColors.accent.opacity(0.15))
                                .frame(width: 56, height: 56)

                            Text(String((vm.partnerNickname ?? "?").prefix(1)))
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(HaguruColors.accent)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(vm.partnerNickname ?? "相手")
                                .font(HaguruFont.bodyMedium())
                                .foregroundColor(HaguruColors.textMain)

                            Text(pair.relationshipType.displayName)
                                .font(HaguruFont.caption())
                                .foregroundColor(HaguruColors.textSub)
                        }

                        Spacer()

                        // Connected badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(HaguruColors.primary)
                                .frame(width: 7, height: 7)
                            Text("つながり中")
                                .font(HaguruFont.small())
                                .foregroundColor(HaguruColors.primary)
                        }
                        .padding(.horizontal, HaguruSpacing.xs)
                        .padding(.vertical, HaguruSpacing.xxs)
                        .background(
                            Capsule()
                                .fill(HaguruColors.primary.opacity(0.1))
                        )
                    }

                    Divider()
                        .foregroundColor(HaguruColors.divider)

                    HStack(spacing: HaguruSpacing.md) {
                        infoItem(
                            icon: "calendar",
                            label: "つながり開始",
                            value: pair.createdAt.shortDateString
                        )
                        Divider()
                            .frame(height: 32)
                        infoItem(
                            icon: "heart.fill",
                            label: "関係",
                            value: pair.relationshipType.displayName
                        )
                    }
                }
            }

            // Disconnect button
            Button(role: .destructive) {
                showDisconnectAlert = true
            } label: {
                Label("連携を解除する", systemImage: "link.badge.plus")
                    .font(HaguruFont.caption())
                    .foregroundColor(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Pending View

    private func pendingView(_ pair: PairLink) -> some View {
        VStack(spacing: HaguruSpacing.md) {
            SoftCard {
                VStack(spacing: HaguruSpacing.lg) {
                    VStack(spacing: HaguruSpacing.sm) {
                        Image(systemName: "person.badge.clock")
                            .font(.system(size: 36, weight: .light))
                            .foregroundColor(HaguruColors.special)

                        Text("相手の参加を待っています")
                            .font(HaguruFont.bodyMedium())
                            .foregroundColor(HaguruColors.textMain)

                        Text("招待コードを相手に伝えましょう")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)
                    }

                    InviteCodeCard(code: pair.inviteCode)

                    SecondaryButton(title: "招待コードを共有", icon: "square.and.arrow.up") {
                        shareCode(pair.inviteCode)
                    }
                }
            }
        }
    }

    // MARK: - No Connection View

    private var noConnectionView: some View {
        SoftCard {
            VStack(spacing: HaguruSpacing.lg) {
                VStack(spacing: HaguruSpacing.sm) {
                    Image(systemName: "person.2")
                        .font(.system(size: 44, weight: .light))
                        .foregroundColor(HaguruColors.textSub)

                    Text("まだ誰ともつながっていません")
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)
                        .multilineTextAlignment(.center)

                    Text("招待コードで相手とつながりましょう")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: HaguruSpacing.sm) {
                    PrimaryButton(title: "招待コードを発行する", icon: "person.badge.plus") {
                        showInviteSheet = true
                    }
                    SecondaryButton(title: "コードを入力する", icon: "keyboard") {
                        showEnterCodeSheet = true
                    }
                }
            }
            .padding(.vertical, HaguruSpacing.sm)
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: HaguruSpacing.md) {
                Label("通知設定", systemImage: "bell.fill")
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(HaguruColors.primary)

                VStack(alignment: .leading, spacing: HaguruSpacing.xs) {
                    notificationRow(
                        text: "相手が水やりをしたとき",
                        isEnabled: true
                    )
                    notificationRow(
                        text: "相手がひとこと残したとき",
                        isEnabled: true
                    )
                    notificationRow(
                        text: "今日のリマインダー（20:00）",
                        isEnabled: false
                    )
                }

                Text("設定アプリで詳しく管理できます")
                    .font(HaguruFont.small())
                    .foregroundColor(HaguruColors.textSub)

                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("通知設定を開く", systemImage: "arrow.up.right.square")
                        .font(HaguruFont.captionMedium())
                        .foregroundColor(HaguruColors.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Supporting Views

    private func infoItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(HaguruColors.textSub)
            Text(value)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textMain)
            Text(label)
                .font(HaguruFont.small())
                .foregroundColor(HaguruColors.textSub)
        }
        .frame(maxWidth: .infinity)
    }

    private func notificationRow(text: String, isEnabled: Bool) -> some View {
        HStack {
            Circle()
                .fill(isEnabled ? HaguruColors.primary : HaguruColors.divider)
                .frame(width: 7, height: 7)
            Text(text)
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)
            Spacer()
            Text(isEnabled ? "ON" : "OFF")
                .font(HaguruFont.small())
                .foregroundColor(isEnabled ? HaguruColors.primary : HaguruColors.textSub)
        }
    }

    private func inviteSheet(code: String) -> some View {
        NavigationStack {
            VStack(spacing: HaguruSpacing.xl) {
                HaguruBrandHeader(subtitle: "招待コードを相手に伝えましょう")
                    .padding(.top, HaguruSpacing.xl)

                InviteCodeCard(code: code)

                SecondaryButton(title: "コードを共有する", icon: "square.and.arrow.up") {
                    shareCode(code)
                }

                Spacer()
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .background(HaguruColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { showInviteSheet = false }
                        .foregroundColor(HaguruColors.textSub)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func shareCode(_ code: String) {
        let text = "はぐるで一緒に育てよう！\n招待コード: \(code)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let vc = windowScene.keyWindow?.rootViewController {
            vc.present(av, animated: true)
        }
    }
}

#Preview {
    let state = AppState.shared
    state.currentUser = .mockParent
    state.currentPairLink = .mockConnected

    return ConnectionView()
        .environmentObject(state)
}
