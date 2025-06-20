import SwiftUI

struct LIDCountdownCard: View {
    @EnvironmentObject var configStore: ConfigStore

    private var daysUntilRAI: Int? {
        guard let currentConfig = configStore.config, let raiDate = currentConfig.nextImportantDate else {
            return nil
        }
        // Ensure the date is in the future
        guard raiDate > Date() else {
            return nil // Or handle as 0 or a past event message if preferred
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: raiDate))
        return components.day
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LID Countdown")
                .font(.headline)
                .foregroundColor(.primary.opacity(0.8))

            if let days = daysUntilRAI {
                HStack(alignment: .firstTextBaseline) {
                    Text("\(days)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color.purple)
                    Text(days == 1 ? "Day" : "Days")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.purple.opacity(0.9))
                        .padding(.leading, -4) // Adjust spacing
                }
                Text("until your RAI treatment.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Set your RAI date to start the countdown.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer() // Pushes content up if card has fixed height
                Text("Tap to configure")
                    .font(.caption)
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading) // Increased minHeight for content
        .cardStyle()
    }
}

#Preview {
    let configStore = ConfigStore.shared
    let previewUserID = UUID()
    
    // Corrected UserConfig initialization
    let sampleConfig = UserConfig(
        user_id: previewUserID, 
        logSymptoms: true, 
        trackAppointments: true, 
        manageMedications: true, 
        nextImportantDate: nil, // or Calendar.current.date(byAdding: .day, value: 10, to: Date())! for future date
        meds: []
    )
    configStore.config = sampleConfig

    let journeyStore = JourneyStore.shared
    // Ensure JourneyProfile initializer is also up-to-date if it changed (it uses user_id correctly)
    journeyStore.profile = JourneyProfile(user_id: previewUserID, condition: .cancer, stage: .raiPrep, onMedication: true, onLID: true)

    return LIDCountdownCard()
        .environmentObject(configStore)
        .environmentObject(journeyStore)
        .padding()
        .frame(width: 300)
} 
