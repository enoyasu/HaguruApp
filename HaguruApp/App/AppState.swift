import SwiftUI
import Combine

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// MARK: - App Screen Enum

enum AppScreen: Equatable {
    case onboarding
    case login
    case signUp
    case nicknameSetup(userID: String)
    case roleSelection(userID: String)
    case relationshipSelection(userID: String)
    case growthObjectSelection(userID: String, pairLinkID: String)
    case waitingForPair(userID: String, pairLinkID: String)
    case enterInviteCode(userID: String)
    case main
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var screen: AppScreen = .onboarding
    @Published var currentUser: HaguruUser?
    @Published var currentPairLink: PairLink?
    @Published var currentGrowthObject: GrowthObject?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let userRepo = UserRepository()
    private let pairRepo = PairLinkRepository()
    private let growthRepo = GrowthObjectRepository()

    #if canImport(FirebaseFirestore)
    private var growthListener: ListenerRegistration?
    private var pairListener: ListenerRegistration?
    #endif

    private init() {}

    // MARK: - Entry

    func onAppear() {
        let auth = AuthService.shared
        guard auth.isAuthenticated, let uid = auth.currentUserID else {
            screen = .onboarding
            return
        }
        Task { await loadUser(uid: uid) }
    }

    // MARK: - Load User & Route

    func loadUser(uid: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            guard let user = try await userRepo.fetchUser(id: uid) else {
                screen = .nicknameSetup(userID: uid)
                return
            }
            currentUser = user

            if let pair = try await pairRepo.fetchPairLink(for: uid) {
                currentPairLink = pair
                if pair.isConnected {
                    let growth = try await growthRepo.fetchGrowthObject(for: pair.id)
                    currentGrowthObject = growth
                    startGrowthListener(pairLinkID: pair.id)
                    screen = .main
                } else {
                    screen = .waitingForPair(userID: uid, pairLinkID: pair.id)
                }
            } else {
                if user.roleType == .child {
                    screen = .relationshipSelection(userID: uid)
                } else {
                    screen = .enterInviteCode(userID: uid)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            screen = .login
        }
    }

    // MARK: - Navigation helpers

    func continueToMain(pair: PairLink, growth: GrowthObject?) {
        currentPairLink = pair
        currentGrowthObject = growth
        if let pairID = pair.isConnected ? pair.id : nil {
            startGrowthListener(pairLinkID: pairID)
        }
        screen = .main
    }

    func signOut() {
        stopListeners()
        currentUser = nil
        currentPairLink = nil
        currentGrowthObject = nil
        try? AuthService.shared.signOut()
        screen = .onboarding
    }

    // MARK: - Realtime Listeners

    private func startGrowthListener(pairLinkID: String) {
        #if canImport(FirebaseFirestore)
        growthListener?.remove()
        growthListener = growthRepo.listenGrowthObject(for: pairLinkID) { [weak self] obj in
            Task { @MainActor [weak self] in
                self?.currentGrowthObject = obj
            }
        } as? ListenerRegistration
        #endif
    }

    private func stopListeners() {
        #if canImport(FirebaseFirestore)
        growthListener?.remove()
        pairListener?.remove()
        growthListener = nil
        pairListener = nil
        #endif
    }
}
