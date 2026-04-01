import Foundation
import Combine
import UIKit

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

#if canImport(GoogleSignIn)
import GoogleSignIn
import GoogleSignInSwift
#endif

// MARK: - Auth Errors

enum HaguruAuthError: LocalizedError {
    case notConfigured
    case signInFailed(String)
    case signUpFailed(String)
    case signOutFailed(String)
    case userNotFound
    case googleSignInCancelled

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "GoogleService-Info.plist がプロジェクトに追加されていません。\nFirebase Console からダウンロードして Xcode に追加してください。"
        case .signInFailed(let msg):
            return "ログインに失敗しました：\(msg)"
        case .signUpFailed(let msg):
            return "登録に失敗しました：\(msg)"
        case .signOutFailed(let msg):
            return "サインアウトに失敗しました：\(msg)"
        case .userNotFound:
            return "ユーザー情報が見つかりませんでした"
        case .googleSignInCancelled:
            return "Google ログインがキャンセルされました"
        }
    }
}

// MARK: - Auth Service

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published private(set) var currentUserID: String?
    @Published private(set) var isAuthenticated: Bool = false

    private init() {}

    // MARK: - Setup

    /// FirebaseApp.configure() の直後に呼ぶ
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

    // MARK: - Email / Password

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

    // MARK: - Google Sign-In

    func signInWithGoogle() async throws -> String {
        #if canImport(GoogleSignIn) && canImport(FirebaseAuth)
        guard FirebaseService.shared.isConfigured else {
            throw HaguruAuthError.notConfigured
        }
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw HaguruAuthError.signInFailed("ウィンドウが見つかりませんでした")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        guard let idToken = result.user.idToken?.tokenString else {
            throw HaguruAuthError.signInFailed("Google トークンの取得に失敗しました")
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        let authResult = try await Auth.auth().signIn(with: credential)
        currentUserID = authResult.user.uid
        isAuthenticated = true
        return authResult.user.uid
        #else
        throw HaguruAuthError.notConfigured
        #endif
    }

    // MARK: - Sign Out

    func signOut() throws {
        #if canImport(FirebaseAuth)
        do {
            try Auth.auth().signOut()
            #if canImport(GoogleSignIn)
            GIDSignIn.sharedInstance.signOut()
            #endif
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

    // MARK: - Dev / Preview helpers

    /// Firebase 未設定時の開発用バイパス（実機テスト用）
    func signInAsDev() {
        currentUserID = "dev-\(UUID().uuidString.prefix(8))"
        isAuthenticated = true
    }

    func simulateSignIn(userID: String) {
        currentUserID = userID
        isAuthenticated = true
    }

    // MARK: - Private

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
