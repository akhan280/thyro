import Foundation

enum CardType: String, Codable, CaseIterable {
    case symptomLog, medicationReminder, lidCountdown,
         raiPrecautions, tgTrend, heartRateLog,
         // foodLookup, // Removed as it's now a tab
         appointments
}

struct CardDescriptor: Identifiable, Codable {
    var id: UUID = .init()
    var type: CardType
    var isEnabled: Bool
} 