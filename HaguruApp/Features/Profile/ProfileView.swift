import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = ProfileViewModel()
    @State private var showSignOutAlert = false
    @State private var showEditNicknameSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HaguruSpacing.lg) {
                    // Profile Card
                    profileCard
                        .padding(.top, HaguruSpacing.sm)

                    // Growth summary
                    if let growth = appState.currentGrowthObject {
                        growthSummaryCard(growth)
                    }

                    // Settings
                    settingsSection

                    // Danger zone
                    dangerSection

                    // App info
                    appInfoSection

                    Spacer(minLength: HaguruSpacing.xl)
                }
                .padding(.horizontal, HaguruSpacing.md)
                .padding(.bottom, HaguruSpacing.xxl)
            }
            .background(HaguruColors.background.ignoresSafeArea())
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showEditNicknameSheet) {
            editNicknameSheet
        }
        .alert("サインアウトしますか？", isPresented: $showSignOutAlert) {
            Button("サインアウト", role: .destructive) {
                appState.signOut()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("再度ログインすれば続きから使えます。")
        }
        .overlay(alignment: .top) {
            if let msg = vm.successMessage {
                successBanner(msg)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { vm.successMessage = nil }
                        }
                    }
            }
        }
        .animation(HaguruAnimation.spring, value: vm.successMessage)
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        SoftCard {
            HStack(spacing: HaguruSpacing.md) {
                // Avatar
                avatarView

                VStack(alignment: .leading, spacing: 4) {
                    Text(appState.currentUser?.nickname ?? "ニックネーム未設定")
                        .font(HaguruFont.title3())
                        .foregroundColor(HaguruColors.textMain)

                    Text(appState.currentUser?.roleType.displayName ?? "")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)

                    Text(appState.currentUser?.email ?? "")
                        .font(HaguruFont.small())
                        .foregroundColor(HaguruColors.textSub)
                }

                Spacer()

                Button {
                    if let current = appState.currentUser?.nickname {
                        vm.startEditingNickname(current: current)
                        showEditNicknameSheet = true
                    }
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(HaguruColors.primary.opacity(0.6))
                }
                .accessibilityLabel("ニックネームを編集")
            }
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(HaguruColors.primary.opacity(0.12))
                .frame(width: 60, height: 60)

            Text(String((appState.currentUser?.nickname ?? "？").prefix(1)))
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(HaguruColors.primary)
        }
    }

    // MARK: - Growth Summary

    private func growthSummaryCard(_ growth: GrowthObject) -> some View {
        SoftCard {
            HStack(spacing: HaguruSpacing.md) {
                Text(growth.currentEmoji)
                    .font(.system(size: 36))

                VStack(alignment: .leading, spacing: 4) {
                    Text(growth.name)
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)

                    HStack(spacing: HaguruSpacing.xs) {
                        Text(growth.currentState.displayName)
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.primary)

                        Text("·")
                            .foregroundColor(HaguruColors.divider)

                        Text("レベル \(growth.level)")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)

                        Text("·")
                            .foregroundColor(HaguruColors.divider)

                        Text("\(growth.growthPoints)pt")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: HaguruSpacing.xs) {
            SectionHeader(title: "設定")
                .padding(.horizontal, HaguruSpacing.xs)

            SoftCard(padding: 0) {
                VStack(spacing: 0) {
                    settingsRow(icon: "bell.fill", color: HaguruColors.special, title: "通知の設定") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }

                    Divider()
                        .padding(.leading, HaguruSpacing.md + 36 + HaguruSpacing.sm)

                    settingsRow(icon: "paintbrush.fill", color: HaguruColors.primary, title: "テーマ（近日公開）") {
                        // Future: theme selection
                    }
                    .disabled(true)
                    .opacity(0.5)
                }
            }
        }
    }

    // MARK: - Danger Section

    private var dangerSection: some View {
        VStack(spacing: HaguruSpacing.xs) {
            SoftCard(padding: 0) {
                VStack(spacing: 0) {
                    settingsRow(icon: "rectangle.portrait.and.arrow.right", color: .red.opacity(0.7), title: "サインアウト") {
                        showSignOutAlert = true
                    }
                }
            }
        }
    }

    // MARK: - App Info

    private var appInfoSection: some View {
        VStack(spacing: HaguruSpacing.xs) {
            HaguruBrandHeader(size: .compact)

            Text("はぐる — やさしくつながる共育アプリ")
                .font(HaguruFont.small())
                .foregroundColor(HaguruColors.textSub)

            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("バージョン \(version)")
                    .font(HaguruFont.small())
                    .foregroundColor(HaguruColors.textSub.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HaguruSpacing.md)
    }

    // MARK: - Supporting

    private func settingsRow(icon: String, color: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: HaguruSpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 34, height: 34)

                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textMain)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(HaguruColors.textSub.opacity(0.5))
            }
            .padding(.horizontal, HaguruSpacing.md)
            .padding(.vertical, HaguruSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func successBanner(_ message: String) -> some View {
        HStack(spacing: HaguruSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(HaguruColors.primary)
            Text(message)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textMain)
        }
        .padding(.horizontal, HaguruSpacing.md)
        .padding(.vertical, HaguruSpacing.sm)
        .background(
            Capsule()
                .fill(HaguruColors.card)
                .shadow(color: HaguruColors.cardShadow, radius: 10, x: 0, y: 4)
        )
        .padding(.top, HaguruSpacing.lg)
    }

    // MARK: - Edit Nickname Sheet

    private var editNicknameSheet: some View {
        NavigationStack {
            VStack(spacing: HaguruSpacing.xl) {
                VStack(spacing: HaguruSpacing.xs) {
                    Text("ニックネームを変更")
                        .font(HaguruFont.title3())
                        .foregroundColor(HaguruColors.textMain)
                        .padding(.top, HaguruSpacing.xl)

                    Text("12文字まで入力できます")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                }

                TextField("ニックネーム", text: $vm.editingNickname)
                    .font(HaguruFont.title3())
                    .multilineTextAlignment(.center)
                    .padding(HaguruSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                            .fill(HaguruColors.card)
                            .shadow(color: HaguruColors.cardShadow, radius: 6, x: 0, y: 2)
                    )
                    .onChange(of: vm.editingNickname) { _, new in
                        if new.count > 12 { vm.editingNickname = String(new.prefix(12)) }
                    }

                PrimaryButton(
                    title: "保存する",
                    isLoading: vm.isSaving,
                    isDisabled: vm.editingNickname.trimmingCharacters(in: .whitespaces).isEmpty
                ) {
                    Task {
                        guard let uid = appState.currentUser?.id else { return }
                        await vm.saveNickname(userID: uid)
                        if let updated = try? await UserRepository().fetchUser(id: uid) {
                            appState.currentUser = updated
                        }
                        showEditNicknameSheet = false
                    }
                }

                Spacer()
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .background(HaguruColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { showEditNicknameSheet = false }
                        .foregroundColor(HaguruColors.textSub)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    let state = AppState.shared
    state.currentUser = .mockParent
    state.currentPairLink = .mockConnected
    state.currentGrowthObject = .mockFlower

    return ProfileView()
        .environmentObject(state)
}
