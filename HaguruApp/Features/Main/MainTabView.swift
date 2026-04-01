import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab: Int, CaseIterable {
        case home, timeline, connection, profile

        var title: String {
            switch self {
            case .home: return "ホーム"
            case .timeline: return "記録"
            case .connection: return "つながり"
            case .profile: return "マイページ"
            }
        }

        var icon: String {
            switch self {
            case .home: return "leaf.fill"
            case .timeline: return "list.bullet.clipboard.fill"
            case .connection: return "person.2.fill"
            case .profile: return "person.circle.fill"
            }
        }

        var iconUnselected: String {
            switch self {
            case .home: return "leaf"
            case .timeline: return "list.bullet.clipboard"
            case .connection: return "person.2"
            case .profile: return "person.circle"
            }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(Tab.home.title, systemImage: selectedTab == .home ? Tab.home.icon : Tab.home.iconUnselected)
                }
                .tag(Tab.home)

            TimelineView()
                .tabItem {
                    Label(Tab.timeline.title, systemImage: selectedTab == .timeline ? Tab.timeline.icon : Tab.timeline.iconUnselected)
                }
                .tag(Tab.timeline)

            ConnectionView()
                .tabItem {
                    Label(Tab.connection.title, systemImage: selectedTab == .connection ? Tab.connection.icon : Tab.connection.iconUnselected)
                }
                .tag(Tab.connection)
                .badge(connectionBadge)

            ProfileView()
                .tabItem {
                    Label(Tab.profile.title, systemImage: selectedTab == .profile ? Tab.profile.icon : Tab.profile.iconUnselected)
                }
                .tag(Tab.profile)
        }
        .tint(HaguruColors.primary)
    }

    private var connectionBadge: Int {
        guard let pair = appState.currentPairLink else { return 0 }
        return pair.isConnected ? 0 : 1
    }
}

#Preview {
    let state = AppState.shared
    state.currentUser = .mockParent
    state.currentPairLink = .mockConnected
    state.currentGrowthObject = .mockFlower

    return MainTabView()
        .environmentObject(state)
        .environmentObject(AuthService.shared)
}
