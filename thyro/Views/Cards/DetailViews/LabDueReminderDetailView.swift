import SwiftUI

struct LabDueReminderDetailView: View {
    @State private var isSetUp: Bool = false // e.g., if a next lab date is set

    var body: some View {
        VStack(spacing: 20) {
            if isSetUp {
                Text("Lab Due Reminder - Active")
                    .font(.title)
                Text("Next Lab Due: [Date Here]") // Placeholder for actual date
                Text("Manage your lab schedule and reminders.")
                Button("Clear Reminder (Debug)") { isSetUp = false }
            } else {
                Text("Lab Due Reminder - Not Set Up")
                    .font(.title)
                Text("Set a reminder for your next lab appointment.")
                Button("Set Next Lab Date") { isSetUp = true }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Lab Due Reminder")
    }
}

#Preview {
    NavigationView {
        LabDueReminderDetailView()
    }
} 