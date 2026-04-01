import Foundation
import Combine

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

// MARK: - Auth Errors

enum HaguruAuthError: LocalizedError {
    case notConfigured
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Firebase が設定されていません。セットアップ手順を確認してください。"
        case .signInFailed(let msg):
            return "ログインに失敗しました：\(msg)"
        case .signUpFailed(let msg):
            return "登録に失敗しました：\(msg)"
        case .signOutFailed(let msg):
            return "サインアウトに失敗しました：\(msg)"
        case .userNotFound:
            return "ユーザー情報が見つかりませんでした"
        }
    }
}

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var currentUserID: String?
    @Published private(set) var isAuthenticated: Bool = false

    private init() {
        // リスナーは Firebase 設定後に App 側から setupAuthStateListener() を呼ぶ
    }

    /// Firebase.configure() 後に一度だけ呼ぶこと
    func setupAuthStateListener() {
        #if canImport(FirebaseAuth)
        guard FirebaseService.shared.isConfigured else { return }
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                self?.currentUserID = user?.uid
                self?.isAuthenticated = user != nil
            }
        }
        #endif
    }

    func signIn(email: String, password: String) async throws {
        #if canImport(FirebaseAuth)
        guard FirebaseService.shared.isConfigured else {
            throw HaguruAuthError.notConfigured
        }
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUserID = result.user.uid
            isAuthenticated = true
        } catch {
            throw HaguruAuthError.signInFailed(localizedMessage(from: error))
        }
        #else
        throw HaguruAuthError.notConfigured
        #endif
    }

    func signUp(email: String, password: String) async throws -> String {
        #if canImport(FirebaseAuth)
        guard FirebaseService.shared.isConfigured else {
            throw HaguruAuthError.notConfigured
        }
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw HaguruAuthError.signUpFailed(localizedMessage(from: error))
        }
        #else
        throw HaguruAuthError.notConfigured
        #endif
    }

    func signOut() throws {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            currentUserID = nil
            isAuthenticated = false
        } catch {
            throw HaguruAuthError.signOutFailed(error.localizedDescription)
        }
        #else
        currentUserID = nil
        isAuthenticated = false
        #endif
    }

    // MARK: - Dev/Preview helpers
    func simulateSignIn(userID: String) {
        currentUserID = userID
        isAuthenticated = true
    }

    private func localizedMessage(from error: Error) -> String {
        #if canImport(FirebaseAuth)
        let code = AuthErrorCode(_bridgedNSError: error as NSError)
        switch code {
        case .wrongPassword, .invalidCredential:
            return "メールアドレスまたはパスワードが正しくありません"
        case .emailAlreadyInUse:
            return "このメールアドレスはすでに使用されています"
        case .invalidEmail:
            return "メールアドレスの形式が正しくありません"
        case .weakPassword:
            return "パスワードは6文字以上にしてください"
        case .userNotFound:
            return "アカウントが見つかりません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        default:
            return error.localizedDescription
        }
        #else
        return error.localizedDescription
        #endif
    }
}
