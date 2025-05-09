import SwiftUI

struct LabDueReminderCard: View {
    var body: some View {
        Text("Lab Due Reminder Card")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .cardStyle()
    }
}

#Preview {
    LabDueReminderCard()
} 