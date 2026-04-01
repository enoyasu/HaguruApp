import SwiftUI

struct TimelineRow: View {
    let log: ActivityLog
    let isCurrentUser: Bool

    var body: some View {
        HStack(alignment: .top, spacing: HaguruSpacing.sm) {
            // Avatar
            avatarView

            VStack(alignment: .leading, spacing: HaguruSpacing.xxs) {
                // Header
                HStack(alignment: .firstTextBaseline, spacing: HaguruSpacing.xs) {
                    Text(log.actorNickname)
                        .font(HaguruFont.captionMedium())
                        .foregroundColor(HaguruColors.textMain)

                    Text(log.actionType.feedMessage)
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)

                    Spacer()

                    Text(log.createdAt.relativeDescription)
                        .font(HaguruFont.small())
                        .foregroundColor(HaguruColors.textSub)
                }

                // Content
                contentView
            }
        }
        .padding(.vertical, HaguruSpacing.sm)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var avatarView: some View {
        Circle()
            .fill(
                isCurrentUser
                    ? HaguruColors.primary.opacity(0.15)
                    : HaguruColors.accent.opacity(0.15)
            )
            .frame(width: 38, height: 38)
            .overlay(
                Text(String(log.actorNickname.prefix(1)))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(isCurrentUser ? HaguruColors.primary : HaguruColors.accent)
            )
    }

    @ViewBuilder
    private var contentView: some View {
        switch log.actionType {
        case .water:
            waterCareContent(icon: "drop.fill", color: HaguruColors.waterBlue, label: "水やり完了")

        case .care:
            waterCareContent(icon: "hand.raised.fill", color: HaguruColors.careGreen, label: "お世話完了")

        case .stamp:
            if let stamp = log.stampType {
                HStack(spacing: HaguruSpacing.xxs) {
                    Text(stamp.emoji)
                        .font(.system(size: 32))
                    Text(stamp.label)
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                }
            }

        case .comment, .diary:
            if let text = log.text, !text.isEmpty {
                Text(text)
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textMain)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(HaguruSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                            .fill(
                                isCurrentUser
                                    ? HaguruColors.primary.opacity(0.08)
                                    : HaguruColors.card
                            )
                    )
            }
        }
    }

    private func waterCareContent(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: HaguruSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)

            Text(label)
                .font(HaguruFont.caption())
                .foregroundColor(HaguruColors.textSub)
        }
        .padding(.horizontal, HaguruSpacing.sm)
        .padding(.vertical, HaguruSpacing.xxs + 2)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Date Extension
extension Date {
    var relativeDescription: String {
        let diff = Date.now.timeIntervalSince(self)
        if diff < 60 { return "たった今" }
        if diff < 3600 { return "\(Int(diff / 60))分前" }
        if diff < 86400 { return "\(Int(diff / 3600))時間前" }
        if diff < 86400 * 7 { return "\(Int(diff / 86400))日前" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }

    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: self)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(ActivityLog.mockLogs) { log in
                TimelineRow(log: log, isCurrentUser: log.actorUserID == HaguruUser.mockParent.id)
                    .padding(.horizontal, HaguruSpacing.md)

                Divider()
                    .padding(.leading, HaguruSpacing.md + 38 + HaguruSpacing.sm)
            }
        }
    }
    .background(HaguruColors.background)
}
