import SwiftUI

enum OnboardingStep {
    case condition, stage, personalization
}

struct OnboardingCoordinator: View {
    @EnvironmentObject var journeyStore: JourneyStore
    @EnvironmentObject var configStore: ConfigStore
    
    @State private var currentStep: OnboardingStep = .condition
    
    // Data collected during onboarding
    @State private var selectedCondition: Condition? = nil
    @State private var selectedStage: Stage? = nil
    @State private var onMedication: Bool = false
    @State private var trackSymptoms: Bool = true // Default
    @State private var labReminders: Bool = true // Default
    @State private var nextImportantDate: Date? = nil
    @State private var medications: [Medication] = []
    
    var onFinishOnboarding: () -> Void // Closure to call when onboarding is complete

    var body: some View {
        NavigationView {
            Group {
                switch currentStep {
                case .condition:
                    ConditionPickerView(selectedCondition: $selectedCondition, onNext: {
                        if selectedCondition != nil {
                            currentStep = .stage
                        }
                    })
                case .stage:
                    if let condition = selectedCondition {
                        StagePickerView(condition: condition, selectedStage: $selectedStage, onNext: {
                            if selectedStage != nil {
                                currentStep = .personalization
                            }
                        })
                    } else {
                        // Should not happen if flow is correct, but good to handle
                        Text("Error: Condition not selected.")
                        Button("Back to Condition") { currentStep = .condition }
                    }
                case .personalization:
                    if let condition = selectedCondition, let stage = selectedStage {
                        PersonalizationView(
                            onMedication: $onMedication,
                            trackSymptoms: $trackSymptoms,
                            labReminders: $labReminders,
                            nextImportantDate: $nextImportantDate,
                            medications: $medications,
                            onFinish: {
                                completeOnboarding(condition: condition, stage: stage)
                            }
                        )
                    } else {
                        // Should not happen
                        Text("Error: Condition or Stage not selected.")
                        Button("Back to Condition") { currentStep = .condition }
                    }
                }
            }
        }
    }
    
    private func completeOnboarding(condition: Condition, stage: Stage) {
        let newProfile = JourneyProfile(condition: condition, 
                                        stage: stage, 
                                        onMedication: onMedication, 
                                        onLID: false) // onLID defaults to false as per spec
        
        let newConfig = UserConfig(trackSymptoms: trackSymptoms, 
                                   labReminders: labReminders, 
                                   nextImportantDate: nextImportantDate, 
                                   meds: medications)
        
        JourneyStore.shared.setProfile(newProfile) // Use setProfile to ensure sink triggers for save/sync
        ConfigStore.shared.setConfig(newConfig)   // Use setConfig for similar reasons
        
        print("Onboarding complete. Profile and Config updated.")
        onFinishOnboarding() // Call the closure to dismiss
    }
}

#Preview {
    OnboardingCoordinator(onFinishOnboarding: { print("Onboarding finished in preview") })
        .environmentObject(JourneyStore.shared)
        .environmentObject(ConfigStore.shared)
} 