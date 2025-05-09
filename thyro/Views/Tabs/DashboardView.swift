import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var configStore: ConfigStore // Changed from JourneyStore to ConfigStore for cards

    var body: some View {
        NavigationView { // Added NavigationView for a title
            ScrollView {
                LazyVStack(spacing: 16) {
                    if configStore.cards.isEmpty {
                        Text("No cards to display based on your current profile and settings.")
                            .padding()
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(configStore.cards) { cardDescriptor in // CardDescriptor is Identifiable
                            CardFactory.make(for: cardDescriptor.type)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(ConfigStore.shared) // Make sure ConfigStore is properly initialized for preview
        .environmentObject(JourneyStore.shared) // JourneyStore might be needed by ConfigStore init
} 