import Foundation
import Combine
import SwiftUI // For @Published

final class ConfigStore: ObservableObject {
    static let shared = ConfigStore()

    // Provide default empty/initial config if loading fails or for new users
    @Published var config: UserConfig? = nil // Initialize as nil
    @Published var cards: [CardDescriptor] = []

    private var cancellables = Set<AnyCancellable>()
    private var currentUserID: UUID? = nil

    // Observe SymptomStore for changes to hasLoggedSymptomsToday
    @ObservedObject private var symptomStore = SymptomStore.shared

    private init() {
        // Observe changes to config and persist/sync
        $config
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            // Combine with the latest value of hasLoggedSymptomsToday from symptomStore
            .combineLatest(symptomStore.$hasLoggedSymptomsToday.debounce(for: .seconds(0.1), scheduler: RunLoop.main)) 
            .sink { [weak self] (updatedConfig, hasLoggedToday) in // Sink now receives a tuple
                guard let self = self else { return }

                if let configToSave = updatedConfig { 
                    if let userID = self.currentUserID, configToSave.user_id == userID {
                        LocalStore.saveConfig(configToSave)
                        SupabaseService.shared.pushConfig(configToSave)
                        if let currentProfile = JourneyStore.shared.profile, currentProfile.user_id == userID {
                            // Pass hasLoggedToday to regenerateCards
                            self.regenerateCards(profile: currentProfile, config: configToSave, hasLoggedToday: hasLoggedToday)
                            print("ConfigStore: Config for UserID \(userID) updated, saved, synced, and cards regenerated (logged today: \(hasLoggedToday)).")
                        } else {
                            print("ConfigStore: Config updated for UserID \(userID), but JourneyProfile not available/mismatched for card regen. Clearing cards.")
                            self.cards = []
                        }
                    } else if self.currentUserID == nil {
                        print("ConfigStore: Warning - Attempted to save config but no currentUserID is set.")
                    } else {
                        print("ConfigStore: Warning - Attempted to save config for a mismatched UserID. Ignoring save.")
                    }
                } else {
                    // Config was set to nil (e.g., user signed out, data cleared)
                    self.cards = [] // Clear cards
                    print("ConfigStore: Config is nil, cards cleared.")
                }
            }
            .store(in: &cancellables)
        
        // Also listen directly to symptomStore.$hasLoggedSymptomsToday for changes that don't involve $config changing
        symptomStore.$hasLoggedSymptomsToday
            .dropFirst() // Avoid initial redundant call if $config sink already handles it
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] hasLoggedToday in
                guard let self = self, let currentConfig = self.config, let currentProfile = JourneyStore.shared.profile,
                      let userID = self.currentUserID, currentConfig.user_id == userID, currentProfile.user_id == userID else {
                    print("ConfigStore: hasLoggedSymptomsToday changed, but current config/profile not ready for card regeneration.")
                    return
                }
                print("ConfigStore: hasLoggedSymptomsToday changed to \(hasLoggedToday). Regenerating cards.")
                self.regenerateCards(profile: currentProfile, config: currentConfig, hasLoggedToday: hasLoggedToday)
            }
            .store(in: &cancellables)
        
        // Removed initial regenerateCards call from init.
        // Card generation will now be triggered by loadConfigForUser or when config/profile are set.
        print("ConfigStore initialized. Config is initially nil. Cards will generate upon data load.")
    }
    
    func loadConfigForUser(userID: UUID) async {
        self.currentUserID = userID
        print("ConfigStore: Attempting to load config for UserID \(userID)...")
        
        var loadedConfig: UserConfig? = nil
        if let serverConfig = await SupabaseService.shared.pullConfig(for: userID) {
            loadedConfig = serverConfig
            print("ConfigStore: Config loaded from Supabase for UserID \(userID).")
        } else if let localConfig = LocalStore.loadConfig(), localConfig.user_id == userID {
            loadedConfig = localConfig
            print("ConfigStore: Config loaded from LocalStore for UserID \(userID).")
        }

        DispatchQueue.main.async {
            self.config = loadedConfig
            if loadedConfig == nil {
                print("ConfigStore: No config found for UserID \(userID). Config remains nil.")
            } 
            // Ensure cards are regenerated if profile is already available for this user
            if let currentProfile = JourneyStore.shared.profile, 
               let currentUserID = self.currentUserID, // Ensure currentUserID is used for the check
               currentProfile.user_id == currentUserID, 
               let conf = self.config { // Ensure config is non-nil
                self.regenerateCards(profile: currentProfile, config: conf, hasLoggedToday: self.symptomStore.hasLoggedSymptomsToday)
            }
        }
    }

    // Called by JourneyStore when its profile changes, or internally when config changes
    // Ensure this is only called with valid, non-nil profile and config matching current user
    func regenerateCardsIfNeeded(newProfile: JourneyProfile?, newConfig: UserConfig?) {
        guard let profile = newProfile, let config = newConfig, 
              let currentUserID = self.currentUserID,
              profile.user_id == currentUserID, config.user_id == currentUserID else {
            // If either is nil, or mismatch user, clear cards or do nothing.
            // This prevents regenerating cards with stale or mismatched data.
            if self.cards.isEmpty == false { // Only print/clear if there were cards
                 print("ConfigStore: Cannot regenerate cards due to nil/mismatched profile or config. Clearing cards.")
                 DispatchQueue.main.async { self.cards = [] }
            }
            return
        }
        // Get current hasLoggedToday status from symptomStore
        regenerateCards(profile: profile, config: config, hasLoggedToday: symptomStore.hasLoggedSymptomsToday)
    }

    private func regenerateCards(profile: JourneyProfile, config: UserConfig, hasLoggedToday: Bool) {
        let enabledCardTypes = enabledCards(for: profile, config: config)
        
        var preferredOrder: [CardType] = []
        if enabledCardTypes.contains(.symptomLog) && !hasLoggedToday {
            preferredOrder.append(.symptomLog) // SymptomLog first if not logged today
        }
        // Add other high-priority cards
        if profile.stage == .raiPrep || profile.stage == .raiIsolation {
            if enabledCardTypes.contains(.lidCountdown) && profile.stage == .raiPrep { preferredOrder.append(.lidCountdown) }
            if enabledCardTypes.contains(.raiPrecautions) { preferredOrder.append(.raiPrecautions) }
        }

        let sortedCardTypes = enabledCardTypes.sorted { type1, type2 -> Bool in
            let index1 = preferredOrder.firstIndex(of: type1)
            let index2 = preferredOrder.firstIndex(of: type2)
            let isType1SymptomLogged = (type1 == .symptomLog && hasLoggedToday)
            let isType2SymptomLogged = (type2 == .symptomLog && hasLoggedToday)

            if isType1SymptomLogged && !isType2SymptomLogged { return false } // Logged symptom log goes last
            if !isType1SymptomLogged && isType2SymptomLogged { return true }  // Non-logged symptom log comes before logged one if both not in preferred
            if isType1SymptomLogged && isType2SymptomLogged { return type1.rawValue < type2.rawValue } // Both logged, sort alphabetically

            if let index1 = index1, let index2 = index2 {
                return index1 < index2 
            } else if index1 != nil {
                return true 
            } else if index2 != nil {
                return false 
            } else {
                return type1.rawValue < type2.rawValue
            }
        }

        DispatchQueue.main.async { 
            self.cards = sortedCardTypes.map { CardDescriptor(type: $0, isEnabled: true) }
            print("ConfigStore: Cards regenerated/sorted for UserID \(profile.user_id). LoggedToday: \(hasLoggedToday). Count: \(self.cards.count)")
        }
    }
    
    // Function to update config, e.g., after onboarding or from settings
    // Signature updated to match current UserConfig fields
    func updateConfig(logSymptoms: Bool, trackAppointments: Bool, manageMedications: Bool, nextImportantDate: Date?, meds: [Medication]) {
        guard let userID = self.currentUserID else {
            print("ConfigStore: Cannot updateConfig - currentUserID is nil.")
            return
        }
        let newConfig = UserConfig(user_id: userID, 
                                   logSymptoms: logSymptoms,          // Corrected parameter
                                   trackAppointments: trackAppointments, // Corrected parameter
                                   manageMedications: manageMedications, // Corrected parameter
                                   nextImportantDate: nextImportantDate, 
                                   meds: meds)
        self.setConfig(newConfig) 
    }
    
    // Called by OnboardingCoordinator or other parts of the app
    func setConfig(_ newConfig: UserConfig) {
        // If currentUserID is nil, this is likely the initial setup for this user session.
        // Set currentUserID from the incoming config.
        if self.currentUserID == nil {
            self.currentUserID = newConfig.user_id
            print("ConfigStore: currentUserID was nil, now set to \(newConfig.user_id) from new config.")
        } else if self.currentUserID != newConfig.user_id {
            // If currentUserID is set but doesn't match, it's an error.
            print("ConfigStore: Error - Attempted to set config with mismatched UserID. Store UserID: \(String(describing: self.currentUserID)), Config UserID: \(newConfig.user_id)")
            return
        }
        // Proceed if currentUserID now matches newConfig.user_id
        DispatchQueue.main.async {
            self.config = newConfig
            print("ConfigStore: Config set for UserID \(newConfig.user_id)")
        }
    }

    func clearConfig() {
        self.currentUserID = nil
        DispatchQueue.main.async {
            self.config = nil // This will trigger sink, which should clear cards
        }
        LocalStore.deleteConfig()
        print("ConfigStore: Config cleared.")
    }
} 
