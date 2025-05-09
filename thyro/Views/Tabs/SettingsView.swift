import SwiftUI

struct SettingsView: View {
    // Access to stores if settings need to modify them directly
    // @EnvironmentObject var journeyStore: JourneyStore
    // @EnvironmentObject var configStore: ConfigStore
    
    // Example: Allow toggling trackSymptoms
    // @State private var trackSymptoms: Bool = ConfigStore.shared.config.trackSymptoms

    var onDeleteAccount: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Preferences")) {
                    Text("Settings content placeholder.")
                    // Example Toggle:
                    // Toggle("Track Symptoms", isOn: $trackSymptoms)
                    //     .onChange(of: trackSymptoms) {
                    //         var currentConfig = ConfigStore.shared.config
                    //         currentConfig.trackSymptoms = trackSymptoms
                    //         ConfigStore.shared.setConfig(currentConfig) // This will trigger save and sync
                    //     }
                }
                
                Section(header: Text("Account")) {
                    Button("Sign Out (Placeholder)") {
                        print("Sign out tapped - not implemented")
                        // SupabaseService.shared.signOut()
                        // Potentially clear local data and show onboarding
                    }
                    Button("Delete Account Data") {
                        // Delete local data first
                        LocalStore.deleteProfile()
                        LocalStore.deleteConfig()
                        
                        // Reset in-memory stores to their initial state which load defaults if local is nil.
                        // This avoids immediately saving new default profiles back to LocalStore here.
                        // The stores will re-initialize with defaults when next accessed if their data source is nil.
                        // Effectively, make the stores re-evaluate their initializers:
                        JourneyStore.shared.profile = JourneyStore.shared.profile // Trigger a re-publish, which should re-load or use default if nil after delete
                        ConfigStore.shared.config = ConfigStore.shared.config
                        // A more robust reset might involve a dedicated reset function in each store
                        // or re-initializing them if possible, but that's complex with singletons.
                        // For now, the key is that LocalStore is empty.

                        // Show onboarding
                        onDeleteAccount()
                    }.foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(onDeleteAccount: {})
        .environmentObject(ConfigStore.shared)
        .environmentObject(JourneyStore.shared)
} 