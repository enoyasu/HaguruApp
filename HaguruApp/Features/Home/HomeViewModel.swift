import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var recentLogs: [ActivityLog] = []
    @Published var isLoading = false
    @Published var isActing = false
    @Published var errorMessage: String?
    @Published var lastSuccessAction: ActionType?

    private let logRepo = ActivityLogRepository()
    private let growthRepo = GrowthObjectRepository()

    // Debounce guard: prevent duplicate submissions
    private var lastActionTime: [ActionType: Date] = [:]
    private let debounceInterval: TimeInterval = 2.0

    func load(growthObjectID: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            recentLogs = try await logRepo.fetchLogs(for: growthObjectID, limit: 5)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startListening(growthObjectID: String) {
        _ = logRepo.listenLogs(for: growthObjectID) { [weak self] logs in
            Task { @MainActor [weak self] in
                self?.recentLogs = Array(logs.prefix(5))
            }
        }
    }

    func performAction(
        actionType: ActionType,
        user: HaguruUser,
        growthObject: GrowthObject,
        text: String? = nil,
        stampType: StampType? = nil
    ) async {
        // Debounce guard
        let now = Date.now
        if let last = lastActionTime[actionType], now.timeIntervalSince(last) < debounceInterval {
            return
        }
        lastActionTime[actionType] = now

        guard !isActing else { return }
        isActing = true
        defer { isActing = false }

        let log = ActivityLog(
            id: UUID().uuidString,
            growthObjectID: growthObject.id,
            actorUserID: user.id,
            actorNickname: user.nickname,
            actionType: actionType,
            text: text,
            stampType: stampType,
            createdAt: .now
        )

        do {
            async let logPost: () = logRepo.postLog(log)
            async let pointsAdd: () = growthRepo.addPoints(
                growthObjectID: growthObject.id,
                points: actionType.pointValue
            )
            try await logPost
            try await pointsAdd

            withAnimation(HaguruAnimation.spring) {
                lastSuccessAction = actionType
            }
            // Clear after delay
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { lastSuccessAction = nil }

        } catch {
            errorMessage = "アクションの送信に失敗しました"
        }
    }
}
