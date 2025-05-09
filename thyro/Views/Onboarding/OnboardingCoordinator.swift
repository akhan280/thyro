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
    @State private var onMedication: Bool = false // Default to false, user will select
    @State private var trackSymptoms: Bool = true // Default to true, user can change
    @State private var labReminders: Bool = true  // Default to true, user can change
    // These are no longer set by the new PersonalizationView design, will use defaults from UserConfig or be set elsewhere
    // @State private var nextImportantDate: Date? = nil 
    // @State private var medications: [Medication] = []
    
    var onBackToWelcome: () -> Void        // To go back to WelcomeView from the first step
    var onFinishOnboarding: () -> Void      // Closure to call when onboarding is complete

    var body: some View {
        // The NavigationView is crucial for providing a title bar area if we want custom back buttons there
        // However, current sub-views like ConditionPickerView hide the nav bar.
        // We will add custom back buttons within each view's ZStack or VStack.
        Group { // Removed NavigationView from here, each view is full-screen
            switch currentStep {
            case .condition:
                ConditionPickerView(
                    selectedCondition: $selectedCondition, 
                    onNext: {
                        if selectedCondition != nil {
                            currentStep = .stage
                        }
                    },
                    onBack: onBackToWelcome // Pass the closure
                )
            case .stage:
                if let condition = selectedCondition {
                    StagePickerView(
                        condition: condition, 
                        selectedStageValue: $selectedStage, 
                        onNext: {
                            if selectedStage != nil {
                                currentStep = .personalization
                            }
                        },
                        onBack: { 
                            currentStep = .condition 
                        }
                    )
                } else {
                    // Fallback, should ideally not be reached if logic is correct
                    Text("Error: Condition not selected. Please go back.")
                    Button("Back to Start") { onBackToWelcome() }
                }
            case .personalization:
                if let condition = selectedCondition, let stage = selectedStage {
                    PersonalizationView(
                        onMedication: $onMedication,
                        trackSymptoms: $trackSymptoms,
                        labReminders: $labReminders,
                        onFinish: {
                            completeOnboarding(condition: condition, stage: stage)
                        },
                        onBack: { 
                            currentStep = .stage 
                        }
                    )
                } else {
                    // Fallback
                    Text("Error: Condition or Stage not selected. Please go back.")
                    Button("Back to Start") { onBackToWelcome() }
                }
            }
        }
    }
    
    private func completeOnboarding(condition: Condition, stage: Stage) {
        let isOnLID = (stage == .raiPrep) // Determine onLID status based on the stage

        let newProfile = JourneyProfile(condition: condition, 
                                        stage: stage, 
                                        onMedication: onMedication, 
                                        onLID: isOnLID) // Use the determined onLID status
        
        let newConfig = UserConfig(trackSymptoms: trackSymptoms, 
                                   labReminders: labReminders, 
                                   nextImportantDate: nil, 
                                   meds: [])
        
        JourneyStore.shared.setProfile(newProfile)
        ConfigStore.shared.setConfig(newConfig)
        
        print("Onboarding complete. Profile: \(newProfile), Config: \(newConfig)")
        onFinishOnboarding()
    }
}

#Preview {
    OnboardingCoordinator(
        onBackToWelcome: { print("Preview: Back to Welcome") },
        onFinishOnboarding: { print("Onboarding finished in preview") }
    )
    .environmentObject(JourneyStore.shared)
    .environmentObject(ConfigStore.shared)
} 