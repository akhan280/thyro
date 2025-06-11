import SwiftUI

// MinimalMedicationEditorView is removed as full medication management will be a separate tab/feature.

struct PersonalizationView: View {
    @Binding var onMedication: Bool // Still needed to conditionally show manageMedications toggle
    @Binding var logSymptoms: Bool
    @Binding var trackAppointments: Bool
    @Binding var manageMedications: Bool
    
    var onFinish: () -> Void
    var onBack: () -> Void

    private let backgroundColor = Color(red: 248/255, green: 248/255, blue: 247/255)
    private let textColor = Color.black.opacity(0.8)
    private let questionTextColor = Color.black.opacity(0.7)
    // Button colors can be reused from ConditionPickerView if a shared style is created, or defined here.
    private let buttonBackgroundColor = Color.white
    private let selectedButtonBackgroundColor = Color.purple.opacity(0.1)
    private let selectedBorderColor = Color.purple
    private let unselectedBorderColor = Color.gray.opacity(0.2)

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
                        OnboardingStepIcon(systemName: "person.fill.checkmark", isSelected: true) // Updated icon for personalization
                    }
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding(.trailing, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                Text("Personalize Your Setup")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.bottom, 40)

                ScrollView {
                    VStack(alignment: .leading, spacing: 35) {
                        PersonalizationToggleQuestionView(
                            question: "Are you currently taking any thyroid-related medications?",
                            selection: $onMedication,
                            textColor: questionTextColor,
                            buttonBackgroundColor: buttonBackgroundColor,
                            selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor,
                            unselectedBorderColor: unselectedBorderColor
                        )
                        
                        PersonalizationToggleQuestionView(
                            question: "Enable symptom logging to track how you feel daily?",
                            selection: $logSymptoms,
                            textColor: questionTextColor,
                            buttonBackgroundColor: buttonBackgroundColor,
                            selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor,
                            unselectedBorderColor: unselectedBorderColor
                        )
                        
                        PersonalizationToggleQuestionView(
                            question: "Enable appointment tracking?",
                            selection: $trackAppointments,
                            textColor: questionTextColor,
                            buttonBackgroundColor: buttonBackgroundColor,
                            selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor,
                            unselectedBorderColor: unselectedBorderColor
                        )
                        
                        // Conditionally show the manageMedications toggle if they are on medication
                        if onMedication {
                            PersonalizationToggleQuestionView(
                                question: "Enable medication list management & reminders?",
                                selection: $manageMedications,
                                textColor: questionTextColor,
                                buttonBackgroundColor: buttonBackgroundColor,
                                selectedButtonBackgroundColor: selectedButtonBackgroundColor,
                                selectedBorderColor: selectedBorderColor,
                                unselectedBorderColor: unselectedBorderColor
                            )
                        } else {
                            // Ensure manageMedications is false if not on medication
                            // This is also handled in OnboardingCoordinator, but good for UI consistency.
                            // Text("Medication management will be available if you indicate you are on medication.")
                            //     .font(.caption).foregroundColor(.gray).padding(.leading)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer() // Pushes button to bottom
                
                Button(action: onFinish) {
                    Text("Finish Setup")
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
        .onChange(of: onMedication) { newValue in
            // If user is not on medication, disable medication management feature
            if !newValue {
                manageMedications = false
            }
        }
    }
}

// Reusing YesNoButton style for these toggles, renamed for clarity
struct PersonalizationToggleQuestionView: View {
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
                ToggleButton(title: "Yes", isSelected: selection == true, action: { selection = true },
                            backgroundColor: buttonBackgroundColor, selectedBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor, unselectedBorderColor: unselectedBorderColor, textColor: textColor)
                ToggleButton(title: "No", isSelected: selection == false, action: { selection = false },
                            backgroundColor: buttonBackgroundColor, selectedBackgroundColor: selectedButtonBackgroundColor,
                            selectedBorderColor: selectedBorderColor, unselectedBorderColor: unselectedBorderColor, textColor: textColor)
            }
        }
    }
}

struct ToggleButton: View {
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
        @State var onMed: Bool = true
        @State var logSym: Bool = true
        @State var trackApp: Bool = true
        @State var manageMeds: Bool = true
        
        var body: some View {
            PersonalizationView(
                onMedication: $onMed,
                logSymptoms: $logSym,
                trackAppointments: $trackApp,
                manageMedications: $manageMeds,
                onFinish: { print("Finish Tapped") },
                onBack: { print("Back Tapped from Personalization") }
            )
        }
    }
    return PreviewWrapper()
} 