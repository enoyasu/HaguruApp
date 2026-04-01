import Foundation

// MARK: - Firebase Configuration Guard
// Firebase は SPM で追加する必要があります。
// GoogleService-Info.plist をプロジェクトに追加してから使用してください。

#if canImport(FirebaseCore)
import FirebaseCore
#endif

final class FirebaseService {
    static let shared = FirebaseService()

    private(set) var isConfigured = false

    private init() {}

    func configure() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else {
            isConfigured = true
            return
        }
        // GoogleService-Info.plist が必要です
        // プロジェクトに追加すると自動的に設定されます
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           FileManager.default.fileExists(atPath: path) {
            FirebaseApp.configure()
            isConfigured = true
        } else {
            print("[HaguruApp] ⚠️ GoogleService-Info.plist が見つかりません。Firebase機能はモックモードで動作します。")
            isConfigured = false
        }
        #else
        print("[HaguruApp] ⚠️ FirebaseCore が利用できません。SPMでFirebaseを追加してください。")
        isConfigured = false
        #endif
    }
}
