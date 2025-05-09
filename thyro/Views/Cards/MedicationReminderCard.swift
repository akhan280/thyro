import SwiftUI

struct MedicationReminderCard: View {
    var body: some View {
        Text("Medication Reminder Card")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .cardStyle()
    }
}

#Preview {
    MedicationReminderCard()
} 