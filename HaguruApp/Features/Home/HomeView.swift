import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = HomeViewModel()

    @State private var showCommentSheet = false
    @State private var showStampSheet = false
    @State private var commentText = ""
    @State private var showGrowthAnimation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HaguruSpacing.lg) {
                    // Greeting
                    greetingSection
                        .padding(.top, HaguruSpacing.sm)

                    // Growth card
                    if let growth = appState.currentGrowthObject {
                        growthSection(growth)
                    } else {
                        emptyGrowthCard
                    }

                    // Action buttons
                    actionButtons

                    // Recent activity
                    if !vm.recentLogs.isEmpty {
                        recentSection
                    }
                }
                .padding(.horizontal, HaguruSpacing.md)
                .padding(.bottom, HaguruSpacing.xxl)
            }
            .background(HaguruColors.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HaguruBrandHeader(size: .compact)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let pair = appState.currentPairLink {
                        pairBadge(pair)
                    }
                }
            }
            .overlay {
                if let success = vm.lastSuccessAction {
                    successOverlay(success)
                }
            }
        }
        .sheet(isPresented: $showCommentSheet) {
            commentSheet
        }
        .sheet(isPresented: $showStampSheet) {
            stampSheet
        }
        .task {
            if let growthID = appState.currentGrowthObject?.id {
                await vm.load(growthObjectID: growthID)
                vm.startListening(growthObjectID: growthID)
            }
        }
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(greetingText)
                    .font(HaguruFont.caption())
                    .foregroundColor(HaguruColors.textSub)

                if let user = appState.currentUser {
                    Text("\(user.nickname)さん、こんにちは")
                        .font(HaguruFont.title3())
                        .foregroundColor(HaguruColors.textMain)
                }
            }
            Spacer()

            Text(Date.now.greetingEmoji)
                .font(.system(size: 32))
        }
    }

    // MARK: - Growth Section

    private func growthSection(_ growth: GrowthObject) -> some View {
        VStack(spacing: HaguruSpacing.md) {
            GrowthStatusCard(
                growthObject: growth,
                partnerNickname: partnerNickname
            )

            // Partner info
            if let pair = appState.currentPairLink {
                partnerChip(pair)
            }
        }
    }

    private var emptyGrowthCard: some View {
        SoftCard {
            VStack(spacing: HaguruSpacing.md) {
                Text("🌱")
                    .font(.system(size: 48))

                VStack(spacing: HaguruSpacing.xs) {
                    Text("まだ育てているものがありません")
                        .font(HaguruFont.bodyMedium())
                        .foregroundColor(HaguruColors.textMain)

                    Text("相手とつながって、いっしょに育てましょう")
                        .font(HaguruFont.caption())
                        .foregroundColor(HaguruColors.textSub)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HaguruSpacing.lg)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        SoftCard(padding: HaguruSpacing.lg) {
            VStack(spacing: HaguruSpacing.md) {
                Text("今日できること")
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(HaguruColors.textSub)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: HaguruSpacing.lg) {
                    ActionCircleButton(
                        title: "水やり",
                        icon: "drop.fill",
                        color: HaguruColors.waterBlue
                    ) {
                        Task { await performAction(.water) }
                    }
                    .disabled(appState.currentGrowthObject == nil || vm.isActing)

                    ActionCircleButton(
                        title: "お世話",
                        icon: "hand.raised.fill",
                        color: HaguruColors.careGreen
                    ) {
                        Task { await performAction(.care) }
                    }
                    .disabled(appState.currentGrowthObject == nil || vm.isActing)

                    ActionCircleButton(
                        title: "スタンプ",
                        icon: "face.smiling.fill",
                        color: HaguruColors.accent
                    ) {
                        showStampSheet = true
                    }
                    .disabled(appState.currentGrowthObject == nil || vm.isActing)

                    ActionCircleButton(
                        title: "ひとこと",
                        icon: "bubble.left.fill",
                        color: HaguruColors.special
                    ) {
                        showCommentSheet = true
                    }
                    .disabled(appState.currentGrowthObject == nil || vm.isActing)
                }
            }
        }
    }

    // MARK: - Recent Activity

    private var recentSection: some View {
        VStack(spacing: HaguruSpacing.sm) {
            SectionHeader(title: "最近の記録")

            SoftCard(padding: 0) {
                VStack(spacing: 0) {
                    ForEach(vm.recentLogs) { log in
                        TimelineRow(
                            log: log,
                            isCurrentUser: log.actorUserID == appState.currentUser?.id
                        )
                        .padding(.horizontal, HaguruSpacing.md)

                        if log.id != vm.recentLogs.last?.id {
                            Divider()
                                .padding(.leading, HaguruSpacing.md + 38 + HaguruSpacing.sm)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Supporting Views

    private func partnerChip(_ pair: PairLink) -> some View {
        HStack(spacing: HaguruSpacing.xs) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 13))
                .foregroundColor(HaguruColors.primary)

            Text("\(pair.relationshipType.displayName)でつながっています")
                .font(HaguruFont.small())
                .foregroundColor(HaguruColors.textSub)
        }
        .padding(.horizontal, HaguruSpacing.sm)
        .padding(.vertical, HaguruSpacing.xxs + 2)
        .background(
            Capsule()
                .fill(HaguruColors.surfaceGreen)
        )
    }

    private func pairBadge(_ pair: PairLink) -> some View {
        Circle()
            .fill(pair.isConnected ? HaguruColors.primary.opacity(0.15) : HaguruColors.divider)
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: pair.isConnected ? "person.2.fill" : "person.badge.clock")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(pair.isConnected ? HaguruColors.primary : HaguruColors.textSub)
            )
    }

    private func successOverlay(_ action: ActionType) -> some View {
        VStack {
            Spacer()
            HStack(spacing: HaguruSpacing.sm) {
                Image(systemName: action.sfSymbol)
                    .foregroundColor(HaguruColors.primary)

                Text("\(action.feedMessage) ＋\(action.pointValue)pt")
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(HaguruColors.textMain)
            }
            .padding(.horizontal, HaguruSpacing.md)
            .padding(.vertical, HaguruSpacing.sm)
            .background(
                Capsule()
                    .fill(HaguruColors.card)
                    .shadow(color: HaguruColors.cardShadow, radius: 12, x: 0, y: 4)
            )
            .padding(.bottom, HaguruSpacing.xxl + 60)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Sheets

    private var commentSheet: some View {
        NavigationStack {
            VStack(spacing: HaguruSpacing.lg) {
                Text("ひとこと残す")
                    .font(HaguruFont.title3())
                    .foregroundColor(HaguruColors.textMain)
                    .padding(.top, HaguruSpacing.lg)

                TextEditor(text: $commentText)
                    .font(HaguruFont.body())
                    .foregroundColor(HaguruColors.textMain)
                    .frame(minHeight: 120)
                    .padding(HaguruSpacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                            .fill(HaguruColors.card)
                    )

                PrimaryButton(title: "送る", icon: "paperplane.fill") {
                    Task {
                        await performAction(.comment, text: commentText)
                        commentText = ""
                        showCommentSheet = false
                    }
                }

                Spacer()
            }
            .padding(.horizontal, HaguruSpacing.lg)
            .background(HaguruColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { showCommentSheet = false }
                        .foregroundColor(HaguruColors.textSub)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var stampSheet: some View {
        NavigationStack {
            VStack(spacing: HaguruSpacing.lg) {
                Text("スタンプを送る")
                    .font(HaguruFont.title3())
                    .foregroundColor(HaguruColors.textMain)
                    .padding(.top, HaguruSpacing.lg)

                StampPicker(selectedStamp: .constant(nil)) { stamp in
                    Task {
                        await performAction(.stamp, stampType: stamp)
                        showStampSheet = false
                    }
                }

                Spacer()
            }
            .padding(.horizontal, HaguruSpacing.md)
            .background(HaguruColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { showStampSheet = false }
                        .foregroundColor(HaguruColors.textSub)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private var partnerNickname: String? {
        guard let pair = appState.currentPairLink,
              let user = appState.currentUser else { return nil }
        // Return the other side's placeholder nickname
        return pair.parentUserID == user.id ? "相手" : "お父さん/お母さん"
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "おはようございます"
        case 12..<18: return "こんにちは"
        default: return "こんばんは"
        }
    }

    private func performAction(_ type: ActionType, text: String? = nil, stampType: StampType? = nil) async {
        guard let user = appState.currentUser,
              let growth = appState.currentGrowthObject else { return }
        await vm.performAction(
            actionType: type,
            user: user,
            growthObject: growth,
            text: text,
            stampType: stampType
        )
    }
}

// MARK: - Date Extension
extension Date {
    var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "🌅"
        case 12..<18: return "☀️"
        default: return "🌙"
        }
    }
}

#Preview {
    let state = AppState.shared
    state.currentUser = .mockParent
    state.currentPairLink = .mockConnected
    state.currentGrowthObject = .mockFlower

    return HomeView()
        .environmentObject(state)
}
