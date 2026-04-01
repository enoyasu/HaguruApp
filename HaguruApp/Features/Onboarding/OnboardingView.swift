import SwiftUI

// MARK: - Onboarding Page Model

private struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let accentColor: Color
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        emoji: "🌱",
        title: "ふたりで育てる",
        description: "一緒に小さな命を育てることで、\nいつでも自然につながれます。",
        accentColor: HaguruColors.primary
    ),
    OnboardingPage(
        emoji: "💧",
        title: "毎日10秒でいい",
        description: "水やりやスタンプ、ひとことで\n気持ちを伝えられます。",
        accentColor: HaguruColors.waterBlue
    ),
    OnboardingPage(
        emoji: "📖",
        title: "記録が残る",
        description: "ふたりの行動が\nタイムラインに積み重なっていきます。",
        accentColor: HaguruColors.special
    ),
    OnboardingPage(
        emoji: "✨",
        title: "離れていても",
        description: "どこにいても、同じお花を\nいっしょに育てられます。",
        accentColor: HaguruColors.accent
    ),
]

// MARK: - Onboarding View

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPage = 0
    @State private var showStartOptions = false

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                // Brand header
                brandArea
                    .padding(.top, HaguruSpacing.xxl)

                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        pageContent(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 320)

                // Dots
                pageIndicator
                    .padding(.top, HaguruSpacing.lg)

                Spacer()

                // CTA
                if currentPage == pages.count - 1 || showStartOptions {
                    startOptions
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    nextButton
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .padding(.bottom, HaguruSpacing.xl)
        }
        .onChange(of: currentPage) { _, new in
            withAnimation(HaguruAnimation.spring) {
                showStartOptions = new == pages.count - 1
            }
        }
    }

    // MARK: - Sub Views

    private var backgroundGradient: some View {
        ZStack {
            HaguruColors.background.ignoresSafeArea()

            // Soft decorative circles
            Circle()
                .fill(HaguruColors.primary.opacity(0.07))
                .frame(width: 300, height: 300)
                .offset(x: -80, y: -200)
                .blur(radius: 40)

            Circle()
                .fill(HaguruColors.accent.opacity(0.07))
                .frame(width: 250, height: 250)
                .offset(x: 120, y: 100)
                .blur(radius: 40)
        }
    }

    private var brandArea: some View {
        VStack(spacing: HaguruSpacing.xs) {
            Text("はぐる")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [HaguruColors.primary, HaguruColors.primary.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("やさしくつながる共育アプリ")
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)
                .tracking(1)
        }
    }

    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: HaguruSpacing.lg) {
            // Illustration
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.1))
                    .frame(width: 140, height: 140)

                Text(page.emoji)
                    .font(.system(size: 70))
            }

            // Text
            VStack(spacing: HaguruSpacing.sm) {
                Text(page.title)
                    .font(HaguruFont.title2())
                    .foregroundColor(HaguruColors.textMain)

                Text(page.description)
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textSub)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, HaguruSpacing.sm)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? HaguruColors.primary : HaguruColors.divider)
                    .frame(width: index == currentPage ? 20 : 6, height: 6)
                    .animation(HaguruAnimation.spring, value: currentPage)
            }
        }
    }

    private var nextButton: some View {
        PrimaryButton(title: "次へ", icon: "arrow.right") {
            withAnimation(HaguruAnimation.spring) {
                currentPage = min(currentPage + 1, pages.count - 1)
            }
        }
    }

    private var startOptions: some View {
        VStack(spacing: HaguruSpacing.sm) {
            PrimaryButton(title: "はじめる") {
                appState.screen = .signUp
            }

            SecondaryButton(title: "ログイン") {
                appState.screen = .login
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState.shared)
}
