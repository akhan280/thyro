import Foundation

// Rule Matrix:
// SymptomLog             config.logSymptoms == true
// MedicationReminder     profile.onMedication == true
// LIDCountdown           profile.stage == .raiPrep
// RAIPrecautions         profile.stage == .raiIsolation || profile.stage == .raiPrep
// TgTrend                profile.condition == .cancer && profile.stage == .surveillance
// HeartRateLog           profile.condition == .hyper
// FoodLookup             REMOVED (Now a tab)
// LabDueReminder         REMOVED
// Appointments           config.trackAppointments == true

func enabledCards(for profile: JourneyProfile, config: UserConfig) -> [CardType] {
    return CardType.allCases.filter { cardType in
        switch cardType {
        case .symptomLog:
            return config.logSymptoms
        case .medicationReminder:
            return profile.onMedication
        case .lidCountdown:
            return profile.stage == .raiPrep
        case .raiPrecautions:
            return profile.stage == .raiIsolation || profile.stage == .raiPrep
        case .tgTrend:
            return profile.condition == .cancer && profile.stage == .surveillance
        case .heartRateLog:
            return profile.condition == .hyper
        // case .foodLookup: // Removed
        //     return profile.stage == .raiPrep || profile.stage == .raiIsolation
        // case .labDueReminder: // Removed
        case .appointments:
            return config.trackAppointments
        // default: return false // Not needed if all current cases are handled
        }
    }
} 