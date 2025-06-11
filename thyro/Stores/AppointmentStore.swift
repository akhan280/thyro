import Foundation
import Combine

class AppointmentStore: ObservableObject {
    static let shared = AppointmentStore()

    @Published var appointments: [Appointment] = []
    private var localStoreKey = "appointmentHistory"

    private init() {
        loadAppointments()
        // TODO: Add Supabase sync if appointments are cloud-backed
    }

    func addAppointment(_ appointment: Appointment) {
        appointments.append(appointment)
        sortAppointments()
        saveAppointments()
        // TODO: Push to Supabase
    }

    func updateAppointment(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            appointments[index] = appointment
            sortAppointments()
            saveAppointments()
            // TODO: Push to Supabase
        }
    }

    func deleteAppointment(at offsets: IndexSet) {
        let idsToDelete = offsets.map { appointments[$0].id }
        appointments.remove(atOffsets: offsets)
        saveAppointments()
        // TODO: Delete from Supabase using idsToDelete
    }
    
    func deleteAppointment(id: UUID) {
        appointments.removeAll(where: { $0.id == id })
        saveAppointments()
        // TODO: Delete from Supabase using id
    }

    private func sortAppointments() {
        // Sort by date, upcoming first, then past ones most recent first
        appointments.sort { app1, app2 in
            if app1.date >= Date() && app2.date >= Date() { // Both upcoming or today
                return app1.date < app2.date // Upcoming sooner first
            } else if app1.date >= Date() { // Only app1 is upcoming
                return true
            } else if app2.date >= Date() { // Only app2 is upcoming
                return false
            } else { // Both are past
                return app1.date > app2.date // Most recent past appointment first
            }
        }
    }

    private func saveAppointments() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(appointments) {
            UserDefaults.standard.set(encoded, forKey: localStoreKey)
        } else {
            print("AppointmentStore: Failed to save appointments.")
        }
    }

    private func loadAppointments() {
        if let savedData = UserDefaults.standard.data(forKey: localStoreKey) {
            let decoder = JSONDecoder()
            if let loadedAppointments = try? decoder.decode([Appointment].self, from: savedData) {
                appointments = loadedAppointments
                sortAppointments()
                print("AppointmentStore: Appointments loaded. Count: \(appointments.count)")
                return
            }
        }
        appointments = [] // Sample data for testing
        // For testing, add some sample data if none loaded:
        // appointments = [
        //     Appointment(title: "Endocrinologist Annual Checkup", date: Calendar.current.date(byAdding: .month, value: 2, to: Date())!),
        //     Appointment(title: "TSH & Free T4 Bloodwork", date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, type: .bloodTest)
        // ]
        // sortAppointments()
        print("AppointmentStore: No appointments found or failed to decode.")
    }
    
    // For Debugging/Testing
    func clearAllAppointments() {
        appointments = []
        saveAppointments()
        print("AppointmentStore: All appointments cleared.")
    }
} 