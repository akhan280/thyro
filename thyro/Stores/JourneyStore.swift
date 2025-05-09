import Foundation
import Combine
import SwiftUI // For @Published if not implicitly imported by Combine

final class JourneyStore: ObservableObject {
    static let shared = JourneyStore()
    
    // Provide default empty/initial profile if loading fails or for new users
    @Published var profile: JourneyProfile = LocalStore.loadProfile() ?? JourneyProfile(condition: .hypo, stage: .dx, onMedication: false, onLID: false) // Default placeholder
    
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Observe changes to profile and persist/sync
        $profile
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main) // Debounce to avoid rapid saves
            .sink { [weak self] updatedProfile in
                LocalStore.saveProfile(updatedProfile)
                SupabaseService.shared.pushProfile(updatedProfile)
                print("JourneyStore: Profile updated, saved locally, and queued for sync.")
                // When profile changes, ConfigStore might need to regenerate cards
                // This can be done by ConfigStore observing JourneyStore or via a notification/callback
                ConfigStore.shared.regenerateCardsIfNeeded(newProfile: updatedProfile, newConfig: nil)
            }
            .store(in: &cancellables)
        
        // Initial load from Supabase (optional, could be triggered elsewhere)
        // Task {
        //     if let serverProfile = await SupabaseService.shared.pullProfile() {
        //         DispatchQueue.main.async {
        //             self.profile = serverProfile
        //         }
        //     }
        // }
        print("JourneyStore initialized. Profile loaded: \(profile.id)")
    }
    
    // Function to update profile, e.g., after onboarding
    func updateProfile(condition: Condition, stage: Stage, onMedication: Bool, onLID: Bool) {
        let newProfile = JourneyProfile(condition: condition, stage: stage, onMedication: onMedication, onLID: onLID)
        self.profile = newProfile
        // The sink observer will handle saving and syncing
    }
    
    // Function to set a pre-existing profile (e.g. from onboarding that creates a new one)
    func setProfile(_ newProfile: JourneyProfile) {
        self.profile = newProfile
    }
} 