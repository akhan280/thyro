import Foundation
import Combine
import SwiftUI // For @Published

final class ConfigStore: ObservableObject {
    static let shared = ConfigStore()

    // Provide default empty/initial config if loading fails or for new users
    @Published var config: UserConfig = LocalStore.loadConfig() ?? UserConfig(trackSymptoms: true, labReminders: true, nextImportantDate: nil, meds: []) // Default placeholder
    @Published var cards: [CardDescriptor] = []

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Observe changes to config and persist/sync
        $config
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] updatedConfig in
                guard let self = self else { return }
                LocalStore.saveConfig(updatedConfig)
                SupabaseService.shared.pushConfig(updatedConfig)
                self.regenerateCards(profile: JourneyStore.shared.profile, config: updatedConfig)
                print("ConfigStore: Config updated, saved locally, queued for sync, and cards regenerated.")
            }
            .store(in: &cancellables)
        
        // Initial card generation
        regenerateCards(profile: JourneyStore.shared.profile, config: self.config)
        
        // Initial load from Supabase (optional)
        // Task {
        //     if let serverConfig = await SupabaseService.shared.pullConfig() {
        //         DispatchQueue.main.async {
        //             self.config = serverConfig
        //         }
        //     }
        // }
        print("ConfigStore initialized. Config loaded: \(config.id). Cards generated: \(cards.count)")
    }
    
    // Called by JourneyStore when its profile changes, or internally when config changes
    func regenerateCardsIfNeeded(newProfile: JourneyProfile?, newConfig: UserConfig?) {
        let currentProfile = newProfile ?? JourneyStore.shared.profile
        let currentConfig = newConfig ?? self.config
        regenerateCards(profile: currentProfile, config: currentConfig)
    }

    private func regenerateCards(profile: JourneyProfile, config: UserConfig) {
        let enabledCardTypes = enabledCards(for: profile, config: config)
        self.cards = enabledCardTypes.map { CardDescriptor(type: $0, isEnabled: true) }
        print("ConfigStore: Cards regenerated. Count: \(self.cards.count)")
    }
    
    // Function to update config, e.g., after onboarding or from settings
    func updateConfig(trackSymptoms: Bool, labReminders: Bool, nextImportantDate: Date?, meds: [Medication]) {
        let newConfig = UserConfig(trackSymptoms: trackSymptoms, labReminders: labReminders, nextImportantDate: nextImportantDate, meds: meds)
        self.config = newConfig
        // The sink observer will handle saving, syncing, and card regeneration
    }
    
    func setConfig(_ newConfig: UserConfig) {
        self.config = newConfig
    }
} 