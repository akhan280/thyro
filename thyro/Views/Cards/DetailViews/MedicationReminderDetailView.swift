import SwiftUI

struct MedicationReminderDetailView: View {
    @State private var isSetUp: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            if isSetUp {
                Text("Medication Reminders - Active")
                    .font(.title)
                Text("Display and manage medication schedules here.")
                Button("Mark as Not Set Up (Debug)") { isSetUp = false }
            } else {
                Text("Medication Reminders - Not Set Up")
                    .font(.title)
                Text("Set up reminders for your medications.")
                Button("Configure Medication Reminders") { isSetUp = true }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Medication Reminders")
    }
}

#Preview {
    NavigationView {
        MedicationReminderDetailView()
    }
} 