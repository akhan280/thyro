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
    
    var onFinish: () -> Void
    var onBack: () -> Void

    private let backgroundColor = Color(red: 248/255, green: 248/255, blue: 247/255)
    private let buttonBackgroundColor = Color.white
    private let selectedButtonBackgroundColor = Color.purple.opacity(0.1)
    private let selectedBorderColor = Color.purple
    private let unselectedBorderColor = Color.gray.opacity(0.2)
    private let textColor = Color.black.opacity(0.8)
    private let questionTextColor = Color.black.opacity(0.7)

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Header with Back Button and Step Icons
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.medium))
                            .foregroundColor(textColor)
                    }
                    .padding(.leading, 20)

                    Spacer()
                    
                    HStack(spacing: 12) {
                        OnboardingStepIcon(systemName: "heart.text.square", isSelected: false)
                        OnboardingStepIcon(systemName: "clock", isSelected: false)
                        OnboardingStepIcon(systemName: "pills", isSelected: true) // Third icon selected
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                Text("Let's tune your experience")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.bottom, 40)

                // Questions
                VStack(alignment: .leading, spacing: 30) {
                    PersonalizationQuestionView(
                        question: "Are you currently taking any thyroid-related medications?",
                        selection: $onMedication,
                        textColor: questionTextColor,
                        buttonBackgroundColor: buttonBackgroundColor,
                        selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                        selectedBorderColor: selectedBorderColor,
                        unselectedBorderColor: unselectedBorderColor
                    )
                    
                    PersonalizationQuestionView(
                        question: "Do you want to track your daily symptoms?",
                        selection: $trackSymptoms,
                        textColor: questionTextColor,
                        buttonBackgroundColor: buttonBackgroundColor,
                        selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                        selectedBorderColor: selectedBorderColor,
                        unselectedBorderColor: unselectedBorderColor
                    )
                    
                    PersonalizationQuestionView(
                        question: "Would you like reminders for lab tests or doctor visits?",
                        selection: $labReminders,
                        textColor: questionTextColor,
                        buttonBackgroundColor: buttonBackgroundColor,
                        selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                        selectedBorderColor: selectedBorderColor,
                        unselectedBorderColor: unselectedBorderColor
                    )
                }
                .padding(.horizontal, 20)

                Spacer()
                
                // Finish Button (replaces "Next")
                Button(action: onFinish) {
                    Text("Next") // Image shows "Next", but this is the finish step
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        // No disabled state for this button in the design, it's always active
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                Text("Your data is stored locally")
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.6))
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

struct PersonalizationQuestionView: View {
    let question: String
    @Binding var selection: Bool
    
    let textColor: Color
    let buttonBackgroundColor: Color
    let selectedButtonBackgroundColor: Color
    let selectedBorderColor: Color
    let unselectedBorderColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(question)
                .font(.headline)
                .foregroundColor(textColor)
            
            HStack(spacing: 15) {
                YesNoButton(title: "Yes", isSelected: selection == true, action: { selection = true },
                            backgroundColor: buttonBackgroundColor, selectedBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor, unselectedBorderColor: unselectedBorderColor, textColor: textColor)
                YesNoButton(title: "No", isSelected: selection == false, action: { selection = false },
                            backgroundColor: buttonBackgroundColor, selectedBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor, unselectedBorderColor: unselectedBorderColor, textColor: textColor)
            }
        }
    }
}

struct YesNoButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    let backgroundColor: Color
    let selectedBackgroundColor: Color
    let selectedBorderColor: Color
    let unselectedBorderColor: Color
    let textColor: Color
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? selectedBackgroundColor : backgroundColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? selectedBorderColor : unselectedBorderColor, lineWidth: isSelected ? 2 : 1)
                )
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var onMed: Bool = false
        @State var trackSym: Bool = true
        @State var labRem: Bool = true
        
        var body: some View {
            PersonalizationView(
                onMedication: $onMed,
                trackSymptoms: $trackSym,
                labReminders: $labRem,
                onFinish: { print("Finish Tapped") },
                onBack: { print("Back Tapped from Personalization") }
            )
        }
    }
    return PreviewWrapper()
} 