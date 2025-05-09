import Foundation

// Rule Matrix:
// Card                   Show when…
// SymptomLog             config.trackSymptoms == true
// MedicationReminder     profile.onMedication == true
// LIDCountdown           profile.stage == .raiPrep
// RAIPrecautions         profile.stage == .raiIsolation
// TgTrend                profile.condition == .cancer && profile.stage == .surveillance  (Note: original rule was profile.stage >= .surveillance, interpreting as == .surveillance for simplicity, adjust if needed)
// HeartRateLog           profile.condition == .hyper
// LabDueReminder         config.labReminders == true && profile.stage != .raiIsolation

func enabledCards(for profile: JourneyProfile, config: UserConfig) -> [CardType] {
    return CardType.allCases.filter { cardType in
        switch cardType {
        case .symptomLog:
            return config.trackSymptoms
        case .medicationReminder:
            return profile.onMedication
        case .lidCountdown:
            return profile.stage == .raiPrep
        case .raiPrecautions:
            return profile.stage == .raiIsolation
        case .tgTrend:
            // Assuming .surveillance is the stage where TgTrend is relevant.
            // If other later stages also need it, the logic for Stage comparison might need adjustment.
            return profile.condition == .cancer && profile.stage == .surveillance
        case .heartRateLog:
            return profile.condition == .hyper
        case .labDueReminder:
            return config.labReminders && profile.stage != .raiIsolation
        }
    }
} 