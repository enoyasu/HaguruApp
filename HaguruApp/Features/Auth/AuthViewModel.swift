import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirm = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private let userRepo = UserRepository()

    // MARK: - Validation

    var isSignUpValid: Bool {
        isValidEmail(email) && password.count >= 6 && password == passwordConfirm
    }

    var isSignInValid: Bool {
        isValidEmail(email) && !password.isEmpty
    }

    var passwordMatchError: String? {
        guard !passwordConfirm.isEmpty else { return nil }
        return password != passwordConfirm ? "パスワードが一致しません" : nil
    }

    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return !isValidEmail(email) ? "メールアドレスの形式が正しくありません" : nil
    }

    // MARK: - Sign In

    func signIn(onSuccess: @escaping (String) -> Void) async {
        guard isSignInValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
            if let uid = authService.currentUserID {
                onSuccess(uid)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign Up

    func signUp(onSuccess: @escaping (String) -> Void) async {
        guard isSignUpValid else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let uid = try await authService.signUp(email: email, password: password)
            onSuccess(uid)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
