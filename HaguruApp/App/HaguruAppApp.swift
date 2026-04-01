import SwiftUI

@main
struct HaguruAppApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var authService = AuthService.shared

    init() {
        // ① Firebase を最初に設定
        FirebaseService.shared.configure()
        // ② Firebase 設定後に Auth リスナー登録（キャッシュ済みセッションも捕捉できる）
        AuthService.shared.setupAuthStateListener()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(authService)
                .onAppear {
                    // ③ Combine 購読 → Auth 状態変化で自動ルーティング
                    appState.onAppear()
                    // ④ UIKit Appearance は onAppear で設定（iOS 26 では init より安全）
                    configureAppearance()
                }
        }
    }

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(HaguruColors.card)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(HaguruColors.background)
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(HaguruColors.textMain),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
}

// MARK: - Root Router

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        // ZStack + 明示的な背景色で iOS 26 のブラックスクリーンを防ぐ
        // Group + .animation(value:) は iOS 26 で初回レンダリングが透明になるバグあり
        ZStack {
            // 常に背景を描画してブラックスクリーンを防止
            HaguruColors.background.ignoresSafeArea()

            screenContent
                .animation(HaguruAnimation.gentle, value: appState.screen)
        }
        .overlay(alignment: .top) {
            if let error = appState.errorMessage {
                HaguruErrorBanner(message: error) {
                    appState.errorMessage = nil
                }
                .padding(.horizontal, HaguruSpacing.md)
                .padding(.top, HaguruSpacing.lg)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(HaguruAnimation.spring, value: appState.errorMessage)
            }
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        switch appState.screen {
        case .onboarding:
            OnboardingView()
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        case .nicknameSetup(let userID):
            NicknameSetupView(userID: userID)
        case .roleSelection(let userID):
            RoleSelectionView(userID: userID)
        case .relationshipSelection(let userID):
            RelationshipSelectionView(userID: userID)
        case .growthObjectSelection(let userID, let pairLinkID):
            GrowthObjectSelectionView(userID: userID, pairLinkID: pairLinkID)
        case .waitingForPair(let userID, let pairLinkID):
            WaitingForPairView(userID: userID, pairLinkID: pairLinkID)
        case .enterInviteCode(let userID):
            EnterInviteCodeView(userID: userID)
        case .main:
            MainTabView()
        }
    }
}
