import SwiftUI

struct SymptomLogCard: View {
    @StateObject private var symptomStore = SymptomStore.shared // Use @StateObject for owning the store instance here if it's the primary view for it, or @ObservedObject if passed.
                                                            // For a shared singleton, @ObservedObject is fine.

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: symptomStore.hasLoggedSymptomsToday ? "checkmark.circle.fill" : "figure.feeling.happy")
                    .font(.title2)
                    .foregroundColor(symptomStore.hasLoggedSymptomsToday ? Color.green : Color.orange) // Orange to prompt action
                Text("Symptom Log")
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.9))
            }

            if symptomStore.hasLoggedSymptomsToday {
                Text("Symptoms logged for today. Great job!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Tap to view or edit")
                    .font(.caption)
                    .foregroundColor(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text("How are you feeling today? Don't forget to log your symptoms.")
                    .font(.subheadline)
                    .fontWeight(.medium) // Emphasize prompt
                    .foregroundColor(Color.orange)
                Spacer()
                Text("Tap to log now")
                    .font(.caption.bold())
                    .foregroundColor(Color.accentColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .cardStyle()
        // .onAppear { symptomStore.refreshTodayLogStatus() } // Can be useful if view might appear without store being updated by other means
    }
}

#Preview {
    let symptomStore = SymptomStore.shared
    // To preview different states:
    // symptomStore.hasLoggedSymptomsToday = true
    // symptomStore.hasLoggedSymptomsToday = false
    symptomStore.hasLoggedSymptomsToday = false // Default preview state

    return SymptomLogCard()
        .environmentObject(symptomStore)
        .padding()
        .frame(width: 350)
} 