import SwiftUI

// Helper struct to manage display stages and their mapping to the actual Stage enum
struct DisplayStage: Identifiable, Hashable {
    var displayName: String
    var mapsToStage: Stage // The actual Stage enum case this display option maps to

    var id: String { displayName } // Make displayName the Identifiable ID

    // Explicitly conform to Hashable if needed, though String as ID helps
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }

    static func == (lhs: DisplayStage, rhs: DisplayStage) -> Bool {
        lhs.displayName == rhs.displayName
    }
}

struct StagePickerView: View {
    var condition: Condition
    @Binding var selectedStageValue: Stage?
    var onNext: () -> Void
    var onBack: () -> Void

    @State private var selectedDisplayStage: DisplayStage? = nil

    private let backgroundColor = Color(red: 248/255, green: 248/255, blue: 247/255)
    private let buttonBackgroundColor = Color.white
    private let selectedButtonBackgroundColor = Color.purple.opacity(0.1)
    private let selectedBorderColor = Color.purple
    private let unselectedBorderColor = Color.gray.opacity(0.2)
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
                DisplayStage(displayName: "Hashimoto's (autoimmune)", mapsToStage: .dx),
                DisplayStage(displayName: "Post-thyroidectomy (on meds)", mapsToStage: .postSurgeryOnMeds),
                DisplayStage(displayName: "Subclinical or early-stage", mapsToStage: .dx)
            ]
        case .cancer:
            return [
                DisplayStage(displayName: "Pre-surgery", mapsToStage: .preSurgery),
                DisplayStage(displayName: "Post-thyroidectomy", mapsToStage: .postSurgeryNoMeds),
                DisplayStage(displayName: "Preparing for RAI (LID)", mapsToStage: .raiPrep),
                DisplayStage(displayName: "Post-RAI surveillance", mapsToStage: .surveillance)
            ]
        case .hyper:
            return [
                DisplayStage(displayName: "Graves' disease", mapsToStage: .dx),
                DisplayStage(displayName: "Hashitoxicosis", mapsToStage: .dx),
                DisplayStage(displayName: "Anti-thyroid meds", mapsToStage: .medTitration)
            ]
        }
    }

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
                        OnboardingStepIcon(systemName: "clock", isSelected: true)
                        OnboardingStepIcon(systemName: "pills", isSelected: false)
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding(.trailing, 20)
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
                        StageButton(
                            displayStage: displayStage, 
                            selectedDisplayStage: $selectedDisplayStage,
                            backgroundColor: buttonBackgroundColor,
                            selectedBackgroundColor: selectedButtonBackgroundColor,
                            textColor: textColor,
                            selectedBorderColor: selectedBorderColor,
                            unselectedBorderColor: unselectedBorderColor
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button(action: {
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
    let selectedBackgroundColor: Color
    let textColor: Color
    let selectedBorderColor: Color
    let unselectedBorderColor: Color

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
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(isSelected ? selectedBackgroundColor : backgroundColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : unselectedBorderColor, 
                                lineWidth: isSelected ? 2 : 1)
                )
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var stage: Stage? = nil
        var body: some View {
            StagePickerView(
                condition: .hypo, 
                selectedStageValue: $stage, 
                onNext: { print("Next tapped. Mapped stage: \(String(describing: stage))" ) },
                onBack: { print("Back tapped from StagePicker") }
            )
        }
    }
    return PreviewWrapper()
} 