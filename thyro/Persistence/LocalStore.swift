import Foundation
import SwiftUI // For AppStorage, if used directly

class LocalStore {
    private static let journeyProfileKey = "journeyProfile"
    private static let userConfigKey = "userConfig"

    // MARK: - JourneyProfile
    static func saveProfile(_ profile: JourneyProfile) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(profile) {
            UserDefaults.standard.set(encoded, forKey: journeyProfileKey)
        }
    }

    static func loadProfile() -> JourneyProfile? {
        if let savedProfile = UserDefaults.standard.data(forKey: journeyProfileKey) {
            let decoder = JSONDecoder()
            if let loadedProfile = try? decoder.decode(JourneyProfile.self, from: savedProfile) {
                return loadedProfile
            }
        }
        return nil
    }

    static func deleteProfile() {
        UserDefaults.standard.removeObject(forKey: journeyProfileKey)
    }

    // MARK: - UserConfig
    static func saveConfig(_ config: UserConfig) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(config) {
            UserDefaults.standard.set(encoded, forKey: userConfigKey)
        }
    }

    static func loadConfig() -> UserConfig? {
        if let savedConfig = UserDefaults.standard.data(forKey: userConfigKey) {
            let decoder = JSONDecoder()
            if let loadedConfig = try? decoder.decode(UserConfig.self, from: savedConfig) {
                return loadedConfig
            }
        }
        return nil
    }

    static func deleteConfig() {
        UserDefaults.standard.removeObject(forKey: userConfigKey)
    }
} 