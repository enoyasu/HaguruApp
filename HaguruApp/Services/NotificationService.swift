import Foundation
import UserNotifications

// MARK: - Notification Service
// MVP: ローカル通知。将来 FCM/APNs への拡張を考慮した設計。

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Local Notifications

    func schedulePartnerAction(nickname: String, action: ActionType) {
        let content = UNMutableNotificationContent()
        content.title = "はぐる"
        content.body = notificationBody(nickname: nickname, action: action)
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleGrowthReminder(growthObjectName: String) {
        let content = UNMutableNotificationContent()
        content.title = "はぐる"
        content.body = "\(growthObjectName)が待っています 🌱 少し育ててみる？"
        content.sound = .default

        // 毎日20:00
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "haguru-daily-reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["haguru-daily-reminder"]
        )
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Private

    private func notificationBody(nickname: String, action: ActionType) -> String {
        switch action {
        case .water:
            return "\(nickname)が水やりをしました 💧"
        case .care:
            return "\(nickname)がお世話をしました 🌿"
        case .stamp:
            return "\(nickname)からスタンプが届いています ✨"
        case .comment:
            return "\(nickname)からメッセージが届いています 💬"
        case .diary:
            return "\(nickname)が日記を書きました 📖"
        }
    }
}
