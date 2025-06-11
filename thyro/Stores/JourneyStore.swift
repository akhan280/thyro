import Foundation
import Combine
import SwiftUI // For @Published if not implicitly imported by Combine

final class JourneyStore: ObservableObject {
    static let shared = JourneyStore()
    
    @Published var profile: JourneyProfile? = nil // Initialize as nil
    // We need the user_id to create a sensible default if nothing is loaded.
    // This default should only be created *after* a user session is confirmed.
    
    private var cancellables = Set<AnyCancellable>()
    private var currentUserID: UUID? = nil

    private init() {
        // Sink to save profile changes when profile is non-nil
        $profile
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] updatedProfile in
                guard let self = self, let profileToSave = updatedProfile else { return }
                
                // Ensure the profile being saved matches the current user context
                if let userID = self.currentUserID, profileToSave.user_id == userID {
                    LocalStore.saveProfile(profileToSave)
                    SupabaseService.shared.pushProfile(profileToSave)
                    print("JourneyStore: Profile for UserID \(userID) updated, saved, and queued for sync.")
                    ConfigStore.shared.regenerateCardsIfNeeded(newProfile: profileToSave, newConfig: ConfigStore.shared.config)
                } else if self.currentUserID == nil {
                    print("JourneyStore: Warning - Attempted to save profile but no currentUserID is set.")
                } else {
                    print("JourneyStore: Warning - Attempted to save profile for a mismatched UserID. Ignoring save.")
                }
            }
            .store(in: &cancellables)
        print("JourneyStore initialized. Profile is initially nil.")
    }
    
    func loadProfileForUser(userID: UUID) async {
        self.currentUserID = userID
        print("JourneyStore: Attempting to load profile for UserID \(userID)...")
        
        // Try Supabase first
        if let serverProfile = await SupabaseService.shared.pullProfile(for: userID) {
            DispatchQueue.main.async {
                self.profile = serverProfile
                print("JourneyStore: Profile loaded from Supabase for UserID \(userID).")
            }
            return
        }
        
        // Fallback to LocalStore if Supabase fails or returns nil
        if let localProfile = LocalStore.loadProfile(), localProfile.user_id == userID {
            DispatchQueue.main.async {
                self.profile = localProfile
                print("JourneyStore: Profile loaded from LocalStore for UserID \(userID).")
            }
            return
        }
        
        // If no profile found anywhere, this user doesn't have one yet.
        // Onboarding will create it. If past onboarding, consider creating a default here.
        // For now, profile remains nil, onboarding flow should handle creation.
        print("JourneyStore: No profile found in Supabase or LocalStore for UserID \(userID). Profile remains nil.")
        // If onboarding is complete and profile is still nil, it implies an issue or a new user post-auth setup.
        // For now, we rely on onboarding to create the first profile.
        // To create a default if user is known but profile is missing AFTER onboarding:
        // self.profile = JourneyProfile(user_id: userID, condition: .hypo, stage: .dx, onMedication: false, onLID: false)
    }

    // Called by OnboardingCoordinator or other parts of the app to set a new profile
    func setProfile(_ newProfile: JourneyProfile) {
        // If currentUserID is nil, this is likely the initial setup for this user session.
        // Set currentUserID from the incoming profile.
        if self.currentUserID == nil {
            self.currentUserID = newProfile.user_id
            print("JourneyStore: currentUserID was nil, now set to \(newProfile.user_id) from new profile.")
        } else if self.currentUserID != newProfile.user_id {
            // If currentUserID is set but doesn't match, it's an error.
            print("JourneyStore: Error - Attempted to set profile with mismatched UserID. Store UserID: \(String(describing: self.currentUserID)), Profile UserID: \(newProfile.user_id)")
            return
        }
        // Proceed if currentUserID now matches newProfile.user_id
        DispatchQueue.main.async {
            self.profile = newProfile // This will trigger the sink to save and push
            print("JourneyStore: Profile set for UserID \(newProfile.user_id)")
        }
    }
    
    func clearProfile() {
        self.currentUserID = nil
        DispatchQueue.main.async {
            self.profile = nil
        }
        LocalStore.deleteProfile() // Also clear from local disk
        print("JourneyStore: Profile cleared.")
    }
} 