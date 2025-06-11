import SwiftUI

struct RootTabView: View {
    var onDeleteAccount: () -> Void // For settings
    
    @EnvironmentObject var journeyStore: JourneyStore
    @EnvironmentObject var configStore: ConfigStore // To check config for feature enablement

    // Determine if LID Lookup tab should be shown
    private var shouldShowLIDLookupTab: Bool {
        guard let profile = journeyStore.profile else { return false }
        return profile.stage == .raiPrep || profile.stage == .raiIsolation
    }

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            if shouldShowLIDLookupTab {
                NavigationView {
                    FoodLookupDetailView()
                }
                .tabItem { Label("LID Lookup", systemImage: "magnifyingglass.circle.fill") }
            }
            SymptomLogTabView(onDeleteAccount: onDeleteAccount)
                .tabItem { Label("Symptom Log", systemImage: "heart.text.square.fill") }

            MedicationsTabView() // New Medications Tab
                .tabItem { Label("Medications", systemImage: "pills.fill") }
            
            SettingsView(onDeleteAccount: onDeleteAccount)
                .tabItem { Label("Settings", systemImage:"gearshape.fill") }
        }
        .onAppear {
            // When RootTabView appears (e.g., after onboarding, or app launch)
            // ensure the symptom store refreshes its status for today.
            SymptomStore.shared.refreshTodayLogStatus()
            // Potentially refresh appointmentStore as well if it loads data on init/appear
            // AppointmentStore.shared.loadAppointments() // Or a more specific refresh if needed
        }
    }
}

// Placeholder View for Appointments Tab (until fully implemented)
// AppointmentsTabViewPlaceholder struct definition should be deleted from this file.

// Wrapper View for SymptomLog Tab to handle potential enablement screen
struct SymptomLogTabView: View {
    var onDeleteAccount: () -> Void // For consistency, though not used directly here if nav is separate
    @EnvironmentObject var configStore: ConfigStore

    var body: some View {
        NavigationView {
            if configStore.config?.logSymptoms == true {
                SymptomLogDetailView() // Directly use the existing detail view
            } else {
                EnableFeatureView(featureName: "Symptom Logging", featureDescription: "Track your daily symptoms to understand your health journey better.", configKeyPath: \.logSymptoms)
            }
            // SymptomLogDetailView already has its own .navigationTitle("Symptom Log")
        }
    }
}

// Generic view to prompt enabling a feature
struct EnableFeatureView: View {
    @EnvironmentObject var configStore: ConfigStore
    let featureName: String
    let featureDescription: String
    let configKeyPath: WritableKeyPath<UserConfig, Bool>

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "powersleep") // Example icon
                .font(.system(size: 60))
                .foregroundColor(.orange)
            Text("\(featureName) is Currently Disabled")
                .font(.title2.bold())
            Text(featureDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Enable \(featureName)") {
                if var currentConfig = configStore.config {
                    currentConfig[keyPath: configKeyPath] = true
                    configStore.setConfig(currentConfig)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer()
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

// View for Medications Tab
struct MedicationsTabView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var journeyStore: JourneyStore // To check profile.onMedication

    // For presenting Add/Edit Medication Sheet
    @State private var showingAddEditMedicationSheet = false
    @State private var medicationToEdit: Medication? = nil

    var body: some View {
        NavigationView {
            Group {
                if !(journeyStore.profile?.onMedication ?? false) {
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "pills.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.7))
                        Text("Not on Medication")
                            .font(.title2.bold())
                        Text("Medication tracking is available if you indicate you are on thyroid medication in your profile.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        // Optional: Button to go to profile settings, if such a deep link exists
                        Spacer()
                        Spacer()
                    }
                    .padding()
                } else if configStore.config?.manageMedications == true {
                    // Provide a binding to config.meds, or a constant nil binding if config is nil
                    let medsBinding = Binding<
                        [Medication]?
                    >(
                        get: { self.configStore.config?.meds },
                        set: { newMeds in
                            if var config = self.configStore.config {
                                config.meds = newMeds ?? [] // Ensure meds is not nil in UserConfig if set
                                self.configStore.setConfig(config)
                            }
                        }
                    )
                    MedicationListView(medications: medsBinding, 
                                       showingAddEditSheet: $showingAddEditMedicationSheet, 
                                       medicationToEdit: $medicationToEdit)
                } else {
                    EnableFeatureView(
                        featureName: "Medication Management", 
                        featureDescription: "Keep track of your medications, dosages, and set reminders (reminders coming soon!).", 
                        configKeyPath: \.manageMedications
                    )
                }
            }
            .navigationTitle("Medications")
            .toolbar {
                 // Show Add button only if on medication and feature is enabled
                if journeyStore.profile?.onMedication == true && configStore.config?.manageMedications == true {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            medicationToEdit = nil // New medication
                            showingAddEditMedicationSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddEditMedicationSheet) {
                NavigationView {
                    AddEditMedicationView(
                        medicationToEdit: medicationToEdit,
                        configStore: configStore, // Pass the whole store if needed for user_id context
                        onDismiss: { showingAddEditMedicationSheet = false }
                    )
                }
            }
        }
    }
}

// Placeholder for Medication List View (more details to be filled in)
struct MedicationListView: View {
    @Binding var medications: [Medication]? // Medications from UserConfig (optional)
    @Binding var showingAddEditSheet: Bool
    @Binding var medicationToEdit: Medication?

    var body: some View {
        if let meds = medications, !meds.isEmpty {
            List {
                ForEach(meds) { med in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(med.name).font(.headline)
                            Text("Dose: \(med.doseMg, specifier: "%.2f") \(med.unit)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            medicationToEdit = med
                            showingAddEditSheet = true
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Avoid whole row tap highlight
                    }
                }
                .onDelete(perform: deleteMedication)
            }
        } else {
            ContentUnavailableView(
                "No Medications Added",
                systemImage: "pills.circle",
                description: Text("Tap the '+' button to add your first medication.")
            )
        }
    }
    private func deleteMedication(at offsets: IndexSet) {
        medications?.remove(atOffsets: offsets)
        // Note: This only modifies the local binding. The actual save to ConfigStore
        // needs to happen when setConfig is called after this change.
        // This direct mutation might not trigger ConfigStore's sink immediately unless UserConfig is a class.
        // A better approach is for MedicationListView to have a method that calls a ConfigStore method.
        // For now, this is a simplified local delete.
    }
}

// Placeholder for Add/Edit Medication View
struct AddEditMedicationView: View {
    var medicationToEdit: Medication?
    @ObservedObject var configStore: ConfigStore // To save the updated config
    var onDismiss: () -> Void

    @State private var name: String = ""
    @State private var doseMgString: String = ""
    @State private var unit: String = "mcg"
    let units = ["mcg", "mg", "g", "mL", "IU"]
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section("Medication Details") {
                TextField("Medication Name (e.g., Levothyroxine)", text: $name)
                HStack {
                    TextField("Dose", text: $doseMgString)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    .labelsHidden()
                }
            }
        }
        .navigationTitle(medicationToEdit == nil ? "Add Medication" : "Edit Medication")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onDismiss)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(medicationToEdit == nil ? "Add" : "Save") {
                    saveMedication()
                    onDismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(doseMgString) == nil)
            }
        }
        .onAppear {
            if let med = medicationToEdit {
                name = med.name
                doseMgString = "\(med.doseMg)"
                unit = med.unit
            } else {
                // Defaults for a new medication
                name = ""
                doseMgString = ""
                unit = "mcg"
            }
        }
    }

    private func saveMedication() {
        guard var currentConfig = configStore.config, 
              let dose = Double(doseMgString) else { return }

        let newMed = Medication(id: medicationToEdit?.id ?? UUID(), name: name, doseMg: dose, unit: unit)

        if let index = currentConfig.meds.firstIndex(where: { $0.id == newMed.id }) {
            currentConfig.meds[index] = newMed // Update existing
        } else {
            currentConfig.meds.append(newMed) // Add new
        }
        configStore.setConfig(currentConfig) // This triggers save and sync in ConfigStore
    }
}

#Preview {
    let journeyStore = JourneyStore.shared
    let configStore = ConfigStore.shared
    let symptomStore = SymptomStore.shared // For onAppear
    let appointmentStore = AppointmentStore.shared // Add for previews if any tab needs it
    let previewUserID = UUID()

    journeyStore.profile = JourneyProfile(user_id: previewUserID, condition: .cancer, stage: .raiPrep, onMedication: true, onLID: true)
    configStore.config = UserConfig(user_id: previewUserID, logSymptoms: true, trackAppointments: true, manageMedications: true)
    configStore.config?.meds = [Medication(name: "Levothyroxine", doseMg: 100, unit: "mcg")] // Add sample med

    return RootTabView(onDeleteAccount: { print("Delete account tapped in preview") })
        .environmentObject(journeyStore)
        .environmentObject(configStore)
        .environmentObject(symptomStore)
        .environmentObject(appointmentStore) // Add to environment for previews
} 
