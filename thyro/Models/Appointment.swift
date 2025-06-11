import Foundation

struct Appointment: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String // e.g., "Endocrinologist Check-up", "Blood Test - TSH, Free T4"
    var doctorName: String?
    var location: String?
    var date: Date
    var notes: String?
    var type: AppointmentType // e.g., Doctor Visit, Blood Test, Scan
    // var user_id: UUID // Add if syncing to Supabase and want to associate with user

    enum AppointmentType: String, Codable, CaseIterable, Hashable {
        case doctorVisit = "Doctor Visit"
        case bloodTest = "Blood Test"
        case imagingScan = "Imaging/Scan" // (Ultrasound, RAI Scan, etc.)
        case procedure = "Procedure"
        case other = "Other"
    }

    init(id: UUID = UUID(), 
         title: String, 
         doctorName: String? = nil, 
         location: String? = nil, 
         date: Date, 
         notes: String? = nil, 
         type: AppointmentType = .doctorVisit) {
        self.id = id
        self.title = title
        self.doctorName = doctorName
        self.location = location
        self.date = date
        self.notes = notes
        self.type = type
    }
} 