import Foundation

// Now identified by user_id, which will be the primary key in Supabase
struct UserConfig: Codable, Hashable { // Removed Identifiable or could make user_id the id
    var user_id: UUID // This will store auth.uid()
    var logSymptoms: Bool // Renamed from trackSymptoms
    var trackAppointments: Bool // New
    var manageMedications: Bool // New
    var nextImportantDate: Date? // Kept for LID Countdown, may need a specific LID date field later
    var meds: [Medication] // Assumes Medication is Codable
    // created_at and updated_at can be handled by the database or added here

    // If you need it to be Identifiable for some SwiftUI lists, and user_id is unique:
    // var id: UUID { user_id }

    enum CodingKeys: String, CodingKey {
        case user_id
        case logSymptoms = "log_symptoms"
        case trackAppointments = "track_appointments"
        case manageMedications = "manage_medications"
        case nextImportantDate = "next_important_date"
        case meds
    }
    
    // Default initializer if needed for previews or specific cases
    init(user_id: UUID, logSymptoms: Bool = true, trackAppointments: Bool = true, manageMedications: Bool = true, nextImportantDate: Date? = nil, meds: [Medication] = []) {
        self.user_id = user_id
        self.logSymptoms = logSymptoms
        self.trackAppointments = trackAppointments
        self.manageMedications = manageMedications
        self.nextImportantDate = nextImportantDate
        self.meds = meds
    }
} 