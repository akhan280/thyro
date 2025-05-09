import SwiftUI

// Helper struct to manage display stages and their mapping to the actual Stage enum
struct DisplayStage: Identifiable, Hashable {
    var id = UUID()
    var displayName: String
    var mapsToStage: Stage // The actual Stage enum case this display option maps to
}

struct StagePickerView: View {
    var condition: Condition
    @Binding var selectedStageValue: Stage? // Renamed from selectedStage to avoid conflict with local state
    var onNext: () -> Void

    @State private var selectedDisplayStage: DisplayStage? = nil

    private let backgroundColor = Color(red: 248/255, green: 248/255, blue: 247/255)
    private let buttonBackgroundColor = Color.white
    private let selectedButtonColor = Color.purple.opacity(0.1)
    private let textColor = Color.black.opacity(0.8)

    private var viewTitle: String {
        condition.rawValue.capitalized
    }

    private var subtitle: String {
        switch condition {
        case .hypo, .hyper:
            return "What specifically?"
        case .cancer:
            return "Where are you in your journey?"
        }
    }

    private var availableDisplayStages: [DisplayStage] {
        switch condition {
        case .hypo:
            return [
                DisplayStage(displayName: "Hashimoto's (autoimmune)", mapsToStage: .dx), // Example mapping
                DisplayStage(displayName: "Post-thyroidectomy (on meds)", mapsToStage: .postSurgeryOnMeds),
                DisplayStage(displayName: "Subclinical or early-stage", mapsToStage: .dx)
            ]
        case .cancer:
            return [
                DisplayStage(displayName: "Pre-surgery", mapsToStage: .preSurgery),
                DisplayStage(displayName: "Post-thyroidectomy", mapsToStage: .postSurgeryNoMeds), // Assuming no meds initially
                DisplayStage(displayName: "Preparing for RAI (LID)", mapsToStage: .raiPrep),
                DisplayStage(displayName: "Post-RAI surveillance", mapsToStage: .surveillance)
            ]
        case .hyper:
            return [
                DisplayStage(displayName: "Graves' disease", mapsToStage: .dx), // Example mapping
                DisplayStage(displayName: "Hashitoxicosis", mapsToStage: .dx),
                DisplayStage(displayName: "Anti-thyroid meds", mapsToStage: .medTitration)
            ]
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Onboarding Step Icons
                HStack(spacing: 12) {
                    OnboardingStepIcon(systemName: "heart.text.square", isSelected: false)
                    OnboardingStepIcon(systemName: "clock", isSelected: true)
                    OnboardingStepIcon(systemName: "pills", isSelected: false)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                Text(viewTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(textColor)
                Text(subtitle)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(textColor.opacity(0.7))
                    .padding(.bottom, 30)

                VStack(spacing: 15) {
                    ForEach(availableDisplayStages) { displayStage in
                        StageButton(displayStage: displayStage, 
                                    selectedDisplayStage: $selectedDisplayStage,
                                    backgroundColor: buttonBackgroundColor,
                                    selectedColor: selectedButtonColor,
                                    textColor: textColor
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Next Button
                Button(action: {
                    // Update the binding that OnboardingCoordinator uses
                    selectedStageValue = selectedDisplayStage?.mapsToStage
                    onNext()
                }) {
                    Text("Next")
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
                        .opacity(selectedDisplayStage == nil ? 0.5 : 1.0)
                }
                .disabled(selectedDisplayStage == nil)
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

struct StageButton: View {
    let displayStage: DisplayStage
    @Binding var selectedDisplayStage: DisplayStage?
    let backgroundColor: Color
    let selectedColor: Color
    let textColor: Color

    var isSelected: Bool {
        selectedDisplayStage == displayStage
    }

    var body: some View {
        Button(action: {
            selectedDisplayStage = displayStage
        }) {
            Text(displayStage.displayName)
                .font(.headline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 44) // Ensure decent tap area
                .background(isSelected ? selectedColor : backgroundColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var stage: Stage? = nil
        var body: some View {
            NavigationView { // Keep NavigationView for preview context
                StagePickerView(condition: .hypo, selectedStageValue: $stage, onNext: { print("Next tapped. Mapped stage: \(String(describing: stage))" ) })
            }
        }
    }
    return PreviewWrapper()
} 