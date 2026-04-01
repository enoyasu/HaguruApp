import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = TimelineViewModel()
    @State private var showPostSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    loadingView
                } else if vm.logs.isEmpty {
                    EmptyStateView(
                        icon: "leaf",
                        title: "まだ記録がありません",
                        message: "水やりやひとことを残すと\nここに表示されます",
                        actionTitle: "記録を残す",
                        action: { showPostSheet = true }
                    )
                } else {
                    logList
                }
            }
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPostSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(HaguruColors.primary)
                    }
                    .accessibilityLabel("記録を投稿")
                }
            }
            .background(HaguruColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showPostSheet) {
            PostView { text, mood in
                Task {
                    guard let user = appState.currentUser,
                          let growth = appState.currentGrowthObject else { return }
                    await vm.postDiary(
                        title: "",
                        body: text,
                        mood: mood,
                        user: user,
                        growthObject: growth,
                        logRepo: ActivityLogRepository()
                    )
                }
            }
        }
        .task {
            if let growthID = appState.currentGrowthObject?.id {
                await vm.load(growthObjectID: growthID)
                vm.startListening(growthObjectID: growthID)
            }
        }
        .onDisappear { vm.stopListening() }
    }

    // MARK: - Sub Views

    private var logList: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                let grouped = groupedLogs

                ForEach(grouped.keys.sorted(by: >), id: \.self) { date in
                    Section {
                        ForEach(grouped[date] ?? []) { log in
                            TimelineRow(
                                log: log,
                                isCurrentUser: log.actorUserID == appState.currentUser?.id
                            )
                            .padding(.horizontal, HaguruSpacing.md)

                            if log.id != grouped[date]?.last?.id {
                                Divider()
                                    .padding(.leading, HaguruSpacing.md + 38 + HaguruSpacing.sm)
                            }
                        }
                    } header: {
                        dateSectionHeader(date)
                    }
                }
            }
            .padding(.bottom, HaguruSpacing.xxl)
        }
        .background(HaguruColors.background)
    }

    private func dateSectionHeader(_ date: Date) -> some View {
        HStack {
            Text(date.shortDateString)
                .font(HaguruFont.smallMedium())
                .foregroundColor(HaguruColors.textSub)
            Spacer()
        }
        .padding(.horizontal, HaguruSpacing.md)
        .padding(.vertical, HaguruSpacing.xs)
        .background(HaguruColors.background.opacity(0.95))
    }

    private var loadingView: some View {
        VStack(spacing: HaguruSpacing.md) {
            ForEach(0..<4) { _ in
                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                    .fill(HaguruColors.divider)
                    .frame(height: 60)
                    .shimmer()
            }
        }
        .padding(HaguruSpacing.md)
    }

    private var groupedLogs: [Date: [ActivityLog]] {
        Dictionary(grouping: vm.logs) { log in
            Calendar.current.startOfDay(for: log.createdAt)
        }
    }
}

// MARK: - Post View

struct PostView: View {
    let onPost: (String, MoodType?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var selectedMood: MoodType?
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: HaguruSpacing.lg) {
                    // Mood selector
                    VStack(alignment: .leading, spacing: HaguruSpacing.sm) {
                        Text("今の気持ち")
                            .font(HaguruFont.captionMedium())
                            .foregroundColor(HaguruColors.textSub)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: HaguruSpacing.sm) {
                                ForEach(MoodType.allCases, id: \.self) { mood in
                                    moodChip(mood)
                                }
                            }
                        }
                    }

                    // Text area
                    VStack(alignment: .leading, spacing: HaguruSpacing.xs) {
                        Text("ひとこと・日記")
                            .font(HaguruFont.captionMedium())
                            .foregroundColor(HaguruColors.textSub)

                        TextEditor(text: $text)
                            .font(HaguruFont.body())
                            .foregroundColor(HaguruColors.textMain)
                            .frame(minHeight: 160)
                            .padding(HaguruSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: HaguruRadius.md, style: .continuous)
                                    .fill(HaguruColors.card)
                                    .shadow(color: HaguruColors.cardShadow, radius: 6, x: 0, y: 2)
                            )
                            .focused($focused)
                    }

                    Spacer()
                }
                .padding(HaguruSpacing.lg)
            }
            .background(HaguruColors.background.ignoresSafeArea())
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("今日の記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                        .foregroundColor(HaguruColors.textSub)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("投稿") {
                        onPost(text, selectedMood)
                        dismiss()
                    }
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(text.isEmpty ? HaguruColors.textSub : HaguruColors.primary)
                    .disabled(text.isEmpty)
                }
            }
            .onAppear { focused = true }
        }
        .presentationDetents([.large])
    }

    private func moodChip(_ mood: MoodType) -> some View {
        let isSelected = selectedMood == mood

        return Button {
            withAnimation(HaguruAnimation.spring) {
                selectedMood = isSelected ? nil : mood
            }
        } label: {
            HStack(spacing: HaguruSpacing.xxs) {
                Text(mood.emoji)
                Text(mood.label)
                    .font(HaguruFont.captionMedium())
                    .foregroundColor(isSelected ? HaguruColors.primary : HaguruColors.textSub)
            }
            .padding(.horizontal, HaguruSpacing.sm)
            .padding(.vertical, HaguruSpacing.xs)
            .background(
                Capsule()
                    .fill(isSelected ? HaguruColors.primary.opacity(0.12) : HaguruColors.card)
                    .shadow(color: HaguruColors.cardShadow, radius: 4, x: 0, y: 2)
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        isSelected ? HaguruColors.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TimelineView()
        .environmentObject({
            let state = AppState.shared
            state.currentUser = .mockParent
            state.currentGrowthObject = .mockFlower
            return state
        }())
}
