import Foundation
import Combine

@MainActor
final class TimelineViewModel: ObservableObject {
    @Published var logs: [ActivityLog] = []
    @Published var diaries: [Diary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showPostSheet = false

    private let logRepo = ActivityLogRepository()
    private var listenerHandle: Any?

    func load(growthObjectID: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            logs = try await logRepo.fetchLogs(for: growthObjectID, limit: 50)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func startListening(growthObjectID: String) {
        listenerHandle = logRepo.listenLogs(for: growthObjectID) { [weak self] updated in
            Task { @MainActor [weak self] in
                self?.logs = updated
            }
        }
    }

    func stopListening() {
        listenerHandle = nil
    }

    func postDiary(
        title: String,
        body: String,
        mood: MoodType?,
        user: HaguruUser,
        growthObject: GrowthObject,
        logRepo: ActivityLogRepository
    ) async {
        let log = ActivityLog(
            id: UUID().uuidString,
            growthObjectID: growthObject.id,
            actorUserID: user.id,
            actorNickname: user.nickname,
            actionType: .diary,
            text: body.isEmpty ? title : "\(title)\n\(body)",
            stampType: nil,
            createdAt: .now
        )
        do {
            try await logRepo.postLog(log)
        } catch {
            errorMessage = "投稿に失敗しました"
        }
    }
}
