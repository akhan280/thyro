import SwiftUI

struct CardFactory {
    @ViewBuilder
    static func make(for cardType: CardType) -> some View {
        switch cardType {
        case .symptomLog:
            SymptomLogCard()
        case .medicationReminder:
            MedicationReminderCard()
        case .lidCountdown:
            LIDCountdownCard()
        case .raiPrecautions:
            RAIPrecautionsCard()
        case .tgTrend:
            TgTrendCard()
        case .heartRateLog:
            HeartRateLogCard()
        case .labDueReminder:
            LabDueReminderCard()
        case .foodLookup:
            FoodLookupCard()
        }
    }
} 