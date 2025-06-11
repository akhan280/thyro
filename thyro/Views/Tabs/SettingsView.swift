import SwiftUI

struct SettingsView: View {
    // Access to stores if settings need to modify them directly
    // @EnvironmentObject var journeyStore: JourneyStore
    // @EnvironmentObject var configStore: ConfigStore
    
    // Example: Allow toggling trackSymptoms
    // @State private var trackSymptoms: Bool = ConfigStore.shared.config.trackSymptoms

    var onDeleteAccount: () -> Void
    
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var journeyStore: JourneyStore // For onMedication status
    
    // Create local bindings to the config properties for the Toggles
    // These will read the initial value and then use configStore.setConfig to update.
    // This approach is needed because UserConfig itself is optional in ConfigStore.

    private func binding<Value>(for keyPath: WritableKeyPath<UserConfig, Value>, defaultValue: Value) -> Binding<Value> {
        Binding<Value>(
            get: { configStore.config?[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                if var currentConfig = configStore.config {
                    currentConfig[keyPath: keyPath] = newValue
                    configStore.setConfig(currentConfig)
                }
            }
        )
    }
    
    // Specific binding for manageMedications to handle onMedication dependency
    private var manageMedicationsBinding: Binding<Bool> {
        Binding<Bool>(
            get: { (journeyStore.profile?.onMedication ?? false) && (configStore.config?.manageMedications ?? true) },
            set: { newValue in
                if var currentConfig = configStore.config, journeyStore.profile?.onMedication == true {
                    currentConfig.manageMedications = newValue
                    configStore.setConfig(currentConfig)
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                if configStore.config != nil {
                    Section(header: Text("Feature Preferences")) {
                        Toggle("Enable Symptom Logging", isOn: binding(for: \.logSymptoms, defaultValue: true))
                        Toggle("Enable Appointment Tracking", isOn: binding(for: \.trackAppointments, defaultValue: true))
                        
                        if journeyStore.profile?.onMedication == true {
                            Toggle("Enable Medication Management", isOn: manageMedicationsBinding)
                        } else {
                            HStack {
                                Text("Medication Management")
                                    .foregroundColor(.gray) // Indicate disabled state
                                Spacer()
                                Text("N/A (Not on medication)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    Text("User configuration not loaded yet.")
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Data Management")) {
                    Button("Clear All Symptom Logs (Debug)", role: .destructive) {
                        SymptomStore.shared.clearAllHistory()
                        // Optionally, add an alert to confirm
                    }
                }

                Section(header: Text("Account")) {
                    Button("Sign Out (Placeholder)") {
                        print("Sign out tapped - not implemented")
                        // Would call SupabaseService.shared.signOut() and then trigger app state change
                    }
                    Button("Delete Account Data", role: .destructive, action: onDeleteAccount)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    let configStore = ConfigStore.shared
    let journeyStore = JourneyStore.shared
    let previewUserID = UUID()
    configStore.config = UserConfig(user_id: previewUserID, logSymptoms: true, trackAppointments: true, manageMedications: true)
    journeyStore.profile = JourneyProfile(user_id: previewUserID, condition: .hypo, stage: .dx, onMedication: true, onLID: false)

    return SettingsView(onDeleteAccount: { print("Delete account tapped in preview") })
        .environmentObject(configStore)
        .environmentObject(journeyStore)
} 