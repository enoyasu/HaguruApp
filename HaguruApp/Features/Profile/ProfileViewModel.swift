import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var editingNickname = ""
    @Published var isEditingNickname = false
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    private let userRepo = UserRepository()

    func startEditingNickname(current: String) {
        editingNickname = current
        isEditingNickname = true
    }

    func saveNickname(userID: String) async {
        let trimmed = editingNickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "ニックネームを入力してください"
            return
        }
        isSaving = true
        defer { isSaving = false }
        do {
            try await userRepo.updateNickname(userID: userID, nickname: trimmed)
            isEditingNickname = false
            successMessage = "ニックネームを更新しました"
        } catch {
            errorMessage = "保存に失敗しました"
        }
    }

    func requestNotificationPermission() async -> Bool {
        await NotificationService.shared.requestPermission()
    }
}
