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
                        // Delete local data
                        LocalStore.deleteProfile()
                        LocalStore.deleteConfig()
                        // Reset stores
                        JourneyStore.shared.setProfile(JourneyProfile(condition: .hypo, stage: .dx, onMedication: false, onLID: false))
                        ConfigStore.shared.setConfig(UserConfig(trackSymptoms: true, labReminders: true, nextImportantDate: nil, meds: []))
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