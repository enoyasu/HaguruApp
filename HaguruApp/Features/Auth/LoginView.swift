import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = AuthViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    var body: some View {
        ScrollView {
            VStack(spacing: HaguruSpacing.xl) {
                // Brand
                HaguruBrandHeader(subtitle: "おかえりなさい", size: .regular)
                    .padding(.top, HaguruSpacing.xxl)

                // Form
                VStack(spacing: HaguruSpacing.md) {
                    haguruTextField(
                        title: "メールアドレス",
                        text: $vm.email,
                        icon: "envelope",
                        keyboard: .emailAddress,
                        field: .email
                    )

                    haguruSecureField(
                        title: "パスワード",
                        text: $vm.password,
                        field: .password
                    )

                    if let error = vm.errorMessage {
                        HaguruErrorBanner(message: error) {
                            vm.errorMessage = nil
                        }
                    }
                }

                // CTA
                VStack(spacing: HaguruSpacing.sm) {
                    PrimaryButton(
                        title: "ログイン",
                        isLoading: vm.isLoading,
                        isDisabled: !vm.isSignInValid
                    ) {
                        Task {
                            await vm.signIn { uid in
                                Task { await appState.loadUser(uid: uid) }
                            }
                        }
                    }

                    TextLinkButton(title: "アカウントをお持ちでない方はこちら") {
                        appState.screen = .signUp
                    }
                }

                Spacer()
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

    // MARK: - Field Builders

    private func haguruTextField(
        title: String,
        text: Binding<String>,
        icon: String,
        keyboard: UIKeyboardType = .default,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: HaguruSpacing.xxs) {
            Text(title)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textSub)

            HStack(spacing: HaguruSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(HaguruColors.textSub)
                    .frame(width: 20)

                TextField("", text: text)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: field)
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textMain)
                    .submitLabel(.next)
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
                        focusedField == field ? HaguruColors.primary.opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }

    private func haguruSecureField(
        title: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: HaguruSpacing.xxs) {
            Text(title)
                .font(HaguruFont.captionMedium())
                .foregroundColor(HaguruColors.textSub)

            HStack(spacing: HaguruSpacing.sm) {
                Image(systemName: "lock")
                    .foregroundColor(HaguruColors.textSub)
                    .frame(width: 20)

                SecureField("", text: text)
                    .focused($focusedField, equals: field)
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
                        focusedField == field ? HaguruColors.primary.opacity(0.5) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState.shared)
}
