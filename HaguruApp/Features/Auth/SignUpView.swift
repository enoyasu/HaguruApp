import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = AuthViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case email, password, confirm }

    var body: some View {
        ScrollView {
            VStack(spacing: HaguruSpacing.xl) {
                // Brand
                HaguruBrandHeader(subtitle: "はじめましょう", size: .regular)
                    .padding(.top, HaguruSpacing.xxl)

                // Form
                VStack(spacing: HaguruSpacing.md) {
                    labeledField(
                        title: "メールアドレス",
                        icon: "envelope",
                        error: vm.emailError
                    ) {
                        TextField("", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .password }
                    }

                    labeledField(
                        title: "パスワード（6文字以上）",
                        icon: "lock",
                        error: nil
                    ) {
                        SecureField("", text: $vm.password)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirm }
                    }

                    labeledField(
                        title: "パスワード（確認）",
                        icon: "lock.fill",
                        error: vm.passwordMatchError
                    ) {
                        SecureField("", text: $vm.passwordConfirm)
                            .focused($focusedField, equals: .confirm)
                            .submitLabel(.done)
                            .onSubmit { focusedField = nil }
                    }

                    if let error = vm.errorMessage {
                        HaguruErrorBanner(message: error) {
                            vm.errorMessage = nil
                        }
                    }
                }

                // CTA
                VStack(spacing: HaguruSpacing.sm) {
                    PrimaryButton(
                        title: "アカウントを作成",
                        isLoading: vm.isLoading,
                        isDisabled: !vm.isSignUpValid
                    ) {
                        Task {
                            await vm.signUp { uid in
                                appState.screen = .nicknameSetup(userID: uid)
                            }
                        }
                    }

                    TextLinkButton(title: "すでにアカウントをお持ちの方") {
                        appState.screen = .login
                    }
                }

                Spacer(minLength: HaguruSpacing.xl)
            }
            .padding(.horizontal, HaguruSpacing.lg)
        }
        .background(HaguruColors.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    appState.screen = .onboarding
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(HaguruColors.primary)
                }
            }
        }
    }

    // MARK: - Field Builder

    private func labeledField<Content: View>(
        title: String,
        icon: String,
        error: String?,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: HaguruSpacing.xxs) {
            Text(title)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textSub)

            HStack(spacing: HaguruSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(HaguruColors.textSub)
                    .frame(width: 20)

                content()
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textMain)
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
                        error != nil ? Color.red.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )

            if let error {
                Text(error)
                    .font(HaguruFont.small())
                    .foregroundColor(.red.opacity(0.8))
                    .transition(.opacity)
            }
        }
        .animation(HaguruAnimation.easeOut, value: error)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AppState.shared)
}
