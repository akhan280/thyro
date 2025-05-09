import SwiftUI
// import SwiftData // Removed as it's not used

@main
struct ThyroApp: App {
    @StateObject private var journeyStore = JourneyStore.shared
    @StateObject private var configStore = ConfigStore.shared
    // No need to initialize SupabaseService or OfflineQueue here if they are singletons 
    // and self-initialize or are initialized by stores.

    @State private var showingOnboarding: Bool
    @State private var hasStartedOnboardingFlow: Bool = false // New state to track if user clicked "Get Started"

    init() {
        // Determine if onboarding needs to be shown
        // This check should ideally be robust. If LocalStore.loadProfile() is nil, it means no profile exists.
        let needsOnboarding = LocalStore.loadProfile() == nil
        _showingOnboarding = State(initialValue: needsOnboarding)
        
        print("ThyroApp initialized. Needs Onboarding: \(needsOnboarding)")
        
        // Perform initial Supabase sign-in if necessary (e.g., on first launch or if session expired)
        // This could be a good place, or within SupabaseService init.
        // Task {
        //    await SupabaseService.shared.signInAnonymouslyIfNeeded() // You'd add this method to SupabaseService
        // }
    }

    var body: some Scene {
        WindowGroup {
            if showingOnboarding {
                if !hasStartedOnboardingFlow {
                    WelcomeView(onGetStarted: {
                        hasStartedOnboardingFlow = true
                    })
                } else {
                    OnboardingCoordinator(
                        onBackToWelcome: { // New closure to handle back from the first step of onboarding
                            hasStartedOnboardingFlow = false
                        },
                        onFinishOnboarding: {
                            showingOnboarding = false          // Onboarding is fully complete
                            hasStartedOnboardingFlow = false   // Reset for next time (e.g., after account deletion)
                        }
                    )
                    .environmentObject(journeyStore)
                    .environmentObject(configStore)
                }
            } else {
                RootTabView(onDeleteAccount: {
                    // When account is deleted, reset to show full onboarding again
                    showingOnboarding = true
                    hasStartedOnboardingFlow = false // Ensure WelcomeView is shown first
                    LocalStore.deleteProfile() // Ensure profile is nil for next launch check if app quits now
                    LocalStore.deleteConfig()
                })
                .environmentObject(journeyStore)
                .environmentObject(configStore)
            }
        }
    }
}
