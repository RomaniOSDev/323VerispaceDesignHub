import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs: [FloatingTab] = [
        FloatingTab(id: 0, title: "Designer", systemImage: "paintbrush.fill"),
        FloatingTab(id: 1, title: "Library", systemImage: "books.vertical.fill"),
        FloatingTab(id: 2, title: "Achievements", systemImage: "rosette"),
        FloatingTab(id: 3, title: "Settings", systemImage: "gearshape.fill")
    ]

    var body: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case 0:
                    BrushDesignerView()
                case 1:
                    LibraryContainerView()
                case 2:
                    AchievementsView()
                default:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                FloatingTabBar(selection: $selectedTab, tabs: tabs)
            }
            .studioBackground()
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onReceive(NotificationCenter.default.publisher(for: .openDesignerTab)) { _ in
            selectedTab = 0
        }
    }
}
