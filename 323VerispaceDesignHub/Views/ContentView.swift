import SwiftUI

struct ContentView: View {
    @StateObject private var store = AppStore()

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(store)
        .environment(\.studioTheme, store.studioTheme)
        .animation(.easeInOut(duration: 0.25), value: store.studioTheme)
    }
}
