import SwiftUI

struct AppointmentsCard: View {
    @EnvironmentObject var appointmentStore: AppointmentStore // To get upcoming appointment info

    private var nextAppointment: Appointment? {
        // Find the soonest upcoming appointment
        appointmentStore.appointments.filter { $0.date >= Calendar.current.startOfDay(for: Date()) }.min(by: { $0.date < $1.date })
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(Color.cyan)
                Text("Appointments")
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.9))
            }

            if let appointment = nextAppointment {
                Text("Next: \(appointment.title)")
                    .font(.subheadline.weight(.semibold))
                Text(formattedDate(appointment.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let doctor = appointment.doctorName, !doctor.isEmpty {
                    Text("With: \(doctor)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } else {
                Text("No upcoming appointments scheduled.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            Text("Tap to view all & manage")
                .font(.caption)
                .foregroundColor(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading)
        .cardStyle()
    }
}

#Preview {
    let appointmentStore = AppointmentStore.shared
    // Clear any existing for predictable preview
    // appointmentStore.clearAllAppointments()
    // appointmentStore.addAppointment(Appointment(title: "Endocrinologist Follow-up", date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, type: .doctorVisit))
    // appointmentStore.addAppointment(Appointment(title: "Blood Test", date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, type: .bloodTest))

    return AppointmentsCard()
        .environmentObject(appointmentStore)
        .padding()
        .frame(width: 350)
} 