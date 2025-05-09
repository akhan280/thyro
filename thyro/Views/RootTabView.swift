import SwiftUI

struct RootTabView: View {
    var onDeleteAccount: () -> Void

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage:"house") }
            
            TrackView()
                .tabItem { Label("Track", systemImage:"list.bullet") }
            
            LearnView()
                .tabItem { Label("Learn", systemImage:"book") }
            
            SettingsView(onDeleteAccount: onDeleteAccount)
                .tabItem { Label("Settings", systemImage:"gear") }
        }
    }
}

#Preview {
    RootTabView(onDeleteAccount: {})
        .environmentObject(JourneyStore.shared) // For previews of child views if they need it
        .environmentObject(ConfigStore.shared)
} 