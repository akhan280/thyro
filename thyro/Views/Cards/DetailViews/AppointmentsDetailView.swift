import SwiftUI

struct AppointmentsDetailView: View {
    @StateObject private var appointmentStore = AppointmentStore.shared
    @State private var showingAddAppointmentSheet = false
    @State private var appointmentToEdit: Appointment? = nil

    private var upcomingAppointments: [Appointment] {
        appointmentStore.appointments.filter { $0.date >= Calendar.current.startOfDay(for: Date()) }
    }

    private var pastAppointments: [Appointment] {
        appointmentStore.appointments.filter { $0.date < Calendar.current.startOfDay(for: Date()) }
    }

    var body: some View {
        List {
            if upcomingAppointments.isEmpty && pastAppointments.isEmpty && appointmentStore.appointments.isEmpty {
                 ContentUnavailableView(
                    "No Appointments Yet",
                    systemImage: "calendar.badge.plus",
                    description: Text("Tap the '+' button to add your first appointment.")
                )
            } else {
                if !upcomingAppointments.isEmpty {
                    Section("Upcoming Appointments") {
                        ForEach(upcomingAppointments) { appointment in
                            AppointmentRow(appointment: appointment, store: appointmentStore)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        appointmentStore.deleteAppointment(id: appointment.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
                                        appointmentToEdit = appointment
                                        showingAddAppointmentSheet = true
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                }

                if !pastAppointments.isEmpty {
                    Section("Past Appointments") {
                        ForEach(pastAppointments) { appointment in
                            AppointmentRow(appointment: appointment, store: appointmentStore)
                                .opacity(0.7) // Dim past appointments slightly
                                .swipeActions {
                                    Button(role: .destructive) {
                                        appointmentStore.deleteAppointment(id: appointment.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Appointments")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appointmentToEdit = nil // Ensure it's a new appointment
                    showingAddAppointmentSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showingAddAppointmentSheet) {
            NavigationView { // For sheet title and buttons
                AddEditAppointmentView(
                    appointmentToEdit: appointmentToEdit,
                    store: appointmentStore,
                    onDismiss: { showingAddAppointmentSheet = false }
                )
            }
        }
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    @ObservedObject var store: AppointmentStore // To allow potential direct actions if needed
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func daysUntilOrSince(date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfAppointmentDate = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfAppointmentDate)
        if let day = components.day {
            if day == 0 {
                return "Today"
            } else if day == 1 {
                return "Tomorrow"
            } else if day == -1 {
                return "Yesterday"
            } else if day > 1 {
                return "In \(day) days"
            } else { // day < -1
                return "\(abs(day)) days ago"
            }
        }
        return ""
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.title)
                    .font(.headline)
                Text(formattedDate(appointment.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let doctor = appointment.doctorName, !doctor.isEmpty {
                    Text("With: \(doctor)").font(.caption).foregroundColor(.gray)
                }
                if let location = appointment.location, !location.isEmpty {
                    Text("At: \(location)").font(.caption).foregroundColor(.gray)
                }
            }
            Spacer()
            Text(daysUntilOrSince(date: appointment.date))
                .font(.caption.weight(.medium))
                .foregroundColor(appointment.date < Calendar.current.startOfDay(for: Date()) ? .gray : .blue)
                .padding(6)
                .background((appointment.date < Calendar.current.startOfDay(for: Date()) ? Color.gray.opacity(0.1) : Color.blue.opacity(0.1)))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct AddEditAppointmentView: View {
    var appointmentToEdit: Appointment? // Pass appointment if editing
    @ObservedObject var store: AppointmentStore
    var onDismiss: () -> Void
    
    @State private var title: String = ""
    @State private var doctorName: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
    @State private var notes: String = ""
    @State private var type: Appointment.AppointmentType = .doctorVisit
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Appointment Details")) {
                TextField("Title (e.g., Endocrinologist Check-up)", text: $title)
                DatePicker("Date & Time", selection: $date)
                Picker("Type", selection: $type) {
                    ForEach(Appointment.AppointmentType.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            Section(header: Text("Optional Details")) {
                TextField("Doctor's Name (Optional)", text: $doctorName)
                TextField("Location (Optional)", text: $location)
                TextField("Notes (Optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...)
            }
        }
        .navigationTitle(appointmentToEdit == nil ? "Add Appointment" : "Edit Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onDismiss)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(appointmentToEdit == nil ? "Add" : "Save") {
                    saveAppointment()
                    onDismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            if let appointment = appointmentToEdit {
                title = appointment.title
                doctorName = appointment.doctorName ?? ""
                location = appointment.location ?? ""
                date = appointment.date
                notes = appointment.notes ?? ""
                type = appointment.type
            }
        }
    }
    
    private func saveAppointment() {
        let appointmentData = Appointment(
            id: appointmentToEdit?.id ?? UUID(), // Use existing ID if editing, else new
            title: title, 
            doctorName: doctorName.isEmpty ? nil : doctorName,
            location: location.isEmpty ? nil : location,
            date: date, 
            notes: notes.isEmpty ? nil : notes,
            type: type
        )
        if appointmentToEdit == nil {
            store.addAppointment(appointmentData)
        } else {
            store.updateAppointment(appointmentData)
        }
    }
}


#Preview {
    let appointmentStore = AppointmentStore.shared
    // appointmentStore.addAppointment(Appointment(title: "Endocrinologist Annual Checkup", date: Calendar.current.date(byAdding: .month, value: 2, to: Date())!))
    // appointmentStore.addAppointment(Appointment(title: "TSH & Free T4 Bloodwork", date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, type: .bloodTest))

    return NavigationView {
        AppointmentsDetailView()
            .environmentObject(appointmentStore)
    }
} 