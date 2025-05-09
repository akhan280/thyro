import SwiftUI

// Minimal Medication Editor (Placeholder - expand as needed)
struct MinimalMedicationEditorView: View {
    @Binding var meds: [Medication]
    @State private var showAddMedSheet = false
    @State private var newMedName: String = ""
    @State private var newMedDose: String = ""
    @State private var newMedUnit: String = "mcg"
    
    let units = ["mcg", "mg", "g", "mL"]

    var body: some View {
        Section(header: Text("Medications")) {
            ForEach(meds) { med in
                HStack {
                    Text(med.name)
                    Spacer()
                    Text("\(med.doseMg, specifier: "%.2f") \(med.unit)")
                }
            }
            .onDelete(perform: deleteMed)
            
            Button("Add Medication") {
                showAddMedSheet = true
            }
        }
        .sheet(isPresented: $showAddMedSheet) {
            NavigationView {
                Form {
                    TextField("Medication Name (e.g., Levothyroxine)", text: $newMedName)
                    TextField("Dose (e.g., 100)", text: $newMedDose).keyboardType(.decimalPad)
                    Picker("Unit", selection: $newMedUnit) {
                        ForEach(units, id: \.self) { Text($0) }
                    }
                    Button("Add") {
                        if let dose = Double(newMedDose), !newMedName.isEmpty {
                            meds.append(Medication(name: newMedName, doseMg: dose, unit: newMedUnit))
                            newMedName = ""
                            newMedDose = ""
                            showAddMedSheet = false
                        }
                    }
                }
                .navigationTitle("Add Medication")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAddMedSheet = false } }
                }
            }
        }
    }
    
    private func deleteMed(at offsets: IndexSet) {
        meds.remove(atOffsets: offsets)
    }
}

struct PersonalizationView: View {
    @Binding var onMedication: Bool
    @Binding var trackSymptoms: Bool
    @Binding var labReminders: Bool
    @Binding var nextImportantDate: Date?
    @Binding var medications: [Medication]
    
    var onFinish: () -> Void

    @State private var showDatePicker = false

    var body: some View {
        Form {
            Section(header: Text("Personalize Your Experience")) {
                Toggle("Are you currently on thyroid medication?", isOn: $onMedication)
                Toggle("Track Symptoms?", isOn: $trackSymptoms)
                Toggle("Enable Lab Reminders?", isOn: $labReminders)
                
                HStack {
                    Text("Next Important Date (Optional)")
                    Spacer()
                    if let date = nextImportantDate {
                        Text(date, style: .date)
                            .onTapGesture { showDatePicker = true }
                    } else {
                        Button("Set Date") { showDatePicker = true }
                    }
                }
                if showDatePicker {
                    DatePicker(
                        "Select Date",
                        selection: Binding<Date>(
                            get: { nextImportantDate ?? Date() },
                            set: { nextImportantDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 400)
                    Button("Done selecting date") { showDatePicker = false }
                }
            }
            
            MinimalMedicationEditorView(meds: $medications)
            
            Button("Finish Onboarding") {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Personalization")
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var onMed: Bool = false
        @State var trackSym: Bool = true
        @State var labRem: Bool = true
        @State var nextDate: Date? = nil
        @State var meds: [Medication] = []
        var body: some View {
            NavigationView {
                PersonalizationView(
                    onMedication: $onMed,
                    trackSymptoms: $trackSym,
                    labReminders: $labRem,
                    nextImportantDate: $nextDate,
                    medications: $meds,
                    onFinish: { print("Finish Tapped") }
                )
            }
        }
    }
    return PreviewWrapper()
} 