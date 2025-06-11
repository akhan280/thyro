import SwiftUI
import Supabase // Ensure Supabase is imported if monitoring auth state here
// import SwiftData // Removed as it's not used

@main
struct ThyroApp: App {
    @StateObject private var journeyStore = JourneyStore.shared
    @StateObject private var configStore = ConfigStore.shared
    // SupabaseService.shared is initialized, which handles signInAnonymouslyIfNeeded

    @State private var showingOnboarding: Bool = true // Default to true, logic will adjust
    @State private var hasStartedOnboardingFlow: Bool = false
    @State private var currentUserID: UUID? = nil
    @State private var isLoadingData: Bool = true // To show a loading view initially

    init() {
        // Initial determination of onboarding state can still check LocalStore,
        // but the main logic will be driven by auth state and profile existence for that user.
        // This `showingOnboarding` will be updated by the auth state listener.
        print("ThyroApp initialized. Initial checks will be refined by auth state.")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoadingData {
                    ProgressView("Initializing...") // Or a more sophisticated launch screen
                } else if showingOnboarding {
                    if !hasStartedOnboardingFlow {
                        WelcomeView(onGetStarted: {
                            hasStartedOnboardingFlow = true
                        })
                    } else {
                        OnboardingCoordinator(
                            onBackToWelcome: { hasStartedOnboardingFlow = false },
                            onFinishOnboarding: {
                                // Onboarding is finished, profile & config are set in stores
                                // The auth state listener should have already set currentUserID
                                // The stores would have loaded this new data.
                                showingOnboarding = false
                                hasStartedOnboardingFlow = false
                                // No need to call loadDataForCurrentUser again unless user changed
                            }
                        )
                        .environmentObject(journeyStore)
                        .environmentObject(configStore)
                    }
                } else if currentUserID != nil && (journeyStore.profile != nil && configStore.config != nil) {
                    // Only show RootTabView if we have a user and their data is loaded
                    RootTabView(onDeleteAccount: {
                        Task {
                            await clearUserDataAndShowOnboarding()
                        }
                    })
                    .environmentObject(journeyStore)
                    .environmentObject(configStore)
                    .environmentObject(AppointmentStore.shared)
                    .environmentObject(SymptomStore.shared)
                } else {
                    // This state could mean data is still loading for a known user,
                    // or an error occurred. Or a user exists but has no profile (should go to onboarding).
                    // If currentUserID is known but profile is nil, it means onboarding is needed.
                    if currentUserID != nil && (journeyStore.profile == nil || configStore.config == nil) {
                        // This indicates a state where user is authenticated but profile/config is missing.
                        // This should ideally force onboarding.
                        // The `listenToAuthState` should handle setting showingOnboarding = true in this case.
                        ProgressView("Checking user data...")
                    } else {
                        // Fallback / error or initial loading state before auth is known
                        ProgressView("Loading session...")
                    }
                }
            }
            .task { // Replaces onAppear for async tasks at view appearance
                await listenToAuthState()
            }
        }
    }
    
    private func listenToAuthState() async {
        // Listen to Supabase auth changes
        // Using a direct check initially, and then a listener for subsequent changes.
        isLoadingData = true
        do {
            let session = try await SupabaseService.shared.client.auth.session
            print("ThyroApp: User authenticated with ID: \(session.user.id)")
            await userAuthenticated(userID: session.user.id)
        } catch AuthError.sessionNotFound {
            print("ThyroApp: No Supabase session found on launch.")
            await userNotAuthenticated()
        } catch {
            print("ThyroApp: Error getting initial session: \(error).")
            await userNotAuthenticated()
        }
        isLoadingData = false

        // It's also good practice to listen for subsequent auth events if your app supports sign-out/sign-in changes
        // For anonymous auth that signs in once, this initial check might be sufficient.
        // Example for listener (add to SupabaseService or handle here):
        // For await event in SupabaseService.shared.client.auth.authStateChanges {
        //     if event == .signedIn || event == .userUpdated {
        //         if let userID = try? await SupabaseService.shared.client.auth.session.user.id {
        //             await userAuthenticated(userID: userID)
        //         }
        //     } else if event == .signedOut {
        //         await userNotAuthenticated()
        //     }
        // }
    }

    private func userAuthenticated(userID: UUID) async {
        self.currentUserID = userID
        await journeyStore.loadProfileForUser(userID: userID)
        await configStore.loadConfigForUser(userID: userID)
        
        if journeyStore.profile == nil || configStore.config == nil {
            // If after loading, profile or config is still nil for this authenticated user,
            // it means they haven't completed onboarding or their data is missing.
            print("ThyroApp: User \(userID) authenticated, but profile/config missing. Forcing onboarding.")
            showingOnboarding = true
            hasStartedOnboardingFlow = false // Show WelcomeView first if onboarding is forced
        } else {
            print("ThyroApp: User \(userID) authenticated, profile and config loaded.")
            showingOnboarding = false
        }
        isLoadingData = false
    }
    
    private func userNotAuthenticated() async {
        self.currentUserID = nil
        journeyStore.clearProfile()
        configStore.clearConfig()
        showingOnboarding = true // Always show onboarding if no user
        hasStartedOnboardingFlow = false // Start from WelcomeView
        isLoadingData = false
        print("ThyroApp: User not authenticated. Stores cleared, showing onboarding.")
    }

    private func clearUserDataAndShowOnboarding() async {
        // 1. Clear data from stores (which also deletes from LocalStore)
        journeyStore.clearProfile()
        configStore.clearConfig()

        // 2. Update UI state to show onboarding
        // currentUserID will be nilled out by clearProfile/clearConfig if they also reset currentUserID in store.
        // Or SupabaseService.shared.client.auth.signOut() if we implement full signout
        self.currentUserID = nil // Explicitly nil it here too for clarity
        showingOnboarding = true
        hasStartedOnboardingFlow = false
        print("ThyroApp: User data cleared, showing onboarding.")
        // Note: This doesn't sign out the anonymous Supabase user. 
        // If you want a *new* anonymous user, you'd need Supabase.shared.client.auth.signOut() first,
        // then a new signInAnonymouslyIfNeeded() would trigger for a new ID.
        // For now, deleting local data and re-onboarding under the same anonymous ID is the flow.
    }
}
