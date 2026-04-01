import SwiftUI

struct NicknameSetupView: View {
    @EnvironmentObject private var appState: AppState
    let userID: String

    @State private var nickname = ""
    @State private var isLoading = false
    @State private var error: String?
    @FocusState private var isFocused: Bool

    private let repo = UserRepository()
    private let maxLength = 12

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: HaguruSpacing.xl) {
                // Illustration
                VStack(spacing: HaguruSpacing.md) {
                    Text("👤")
                        .font(.system(size: 64))

                    VStack(spacing: HaguruSpacing.xs) {
                        Text("あなたのなまえは？")
                            .font(HaguruFont.title2())
                            .foregroundColor(HaguruColors.textMain)

                        Text("相手に表示されるニックネームです")
                            .font(HaguruFont.caption())
                            .foregroundColor(HaguruColors.textSub)
                    }
                }

                // Input
                VStack(alignment: .leading, spacing: HaguruSpacing.xs) {
                    TextField("ニックネーム（12文字まで）", text: $nickname)
                        .font(HaguruFont.title3())
                        .foregroundColor(HaguruColors.textMain)
                        .multilineTextAlignment(.center)
                        .focused($isFocused)
                        .onChange(of: nickname) { _, new in
                            if new.count > maxLength {
                                nickname = String(new.prefix(maxLength))
                            }
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

                    HStack {
                        if let error {
                            Text(error)
                                .font(HaguruFont.small())
                                .foregroundColor(.red.opacity(0.8))
                        }
                        Spacer()
                        Text("\(nickname.count)/\(maxLength)")
                            .font(HaguruFont.small())
                            .foregroundColor(HaguruColors.textSub)
                    }
                    .padding(.horizontal, HaguruSpacing.xs)
                }

                // Preview badge
                if !nickname.isEmpty {
                    HStack(spacing: HaguruSpacing.xs) {
                        Circle()
                            .fill(HaguruColors.primary.opacity(0.15))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text(String(nickname.prefix(1)))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(HaguruColors.primary)
                            )

                        Text(nickname)
                            .font(HaguruFont.bodyMedium())
                            .foregroundColor(HaguruColors.textMain)
                    }
                    .padding(.horizontal, HaguruSpacing.md)
                    .padding(.vertical, HaguruSpacing.sm)
                    .background(HaguruColors.surfaceGreen)
                    .clipShape(Capsule())
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .animation(HaguruAnimation.spring, value: nickname.isEmpty)

            Spacer()

            // CTA
            PrimaryButton(
                title: "つぎへ",
                isLoading: isLoading,
                isDisabled: nickname.trimmingCharacters(in: .whitespaces).isEmpty
            ) {
                Task { await saveNickname() }
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .padding(.bottom, HaguruSpacing.xl)
        }
        .background(HaguruColors.background.ignoresSafeArea())
        .onAppear { isFocused = true }
    }

    private func saveNickname() async {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        // Create a minimal user record (role will be set next)
        let user = HaguruUser(
            id: userID,
            nickname: trimmed,
            roleType: .child, // placeholder
            email: AuthService.shared.currentUserID == userID ? "" : ""
        )

        do {
            try await repo.saveUser(user)
            appState.currentUser = user
            appState.screen = .roleSelection(userID: userID)
        } catch {
            self.error = "保存に失敗しました。もう一度お試しください。"
        }
    }
}

#Preview {
    NicknameSetupView(userID: "preview-uid")
        .environmentObject(AppState.shared)
}
