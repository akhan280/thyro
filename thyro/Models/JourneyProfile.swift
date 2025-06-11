import Foundation

enum Condition: String, Codable, CaseIterable {
    case hypo, cancer, hyper
}

enum Stage: String, Codable, CaseIterable {
    case dx                 // newly diagnosed
    case medTitration
    case preSurgery
    case postSurgeryNoMeds
    case postSurgeryOnMeds
    case raiPrep
    case raiIsolation
    case surveillance
}

// Now identified by user_id, which will be the primary key in Supabase
struct JourneyProfile: Codable, Hashable { // Removed Identifiable, or could make user_id the id
    var user_id: UUID // This will store auth.uid()
    var condition: Condition
    var stage: Stage
    var onMedication: Bool
    var onLID: Bool
    // created_at and updated_at can be handled by the database or added here if needed for client-side logic

    // If you need it to be Identifiable for some SwiftUI lists, and user_id is unique:
    // var id: UUID { user_id }

    enum CodingKeys: String, CodingKey {
        case user_id
        case condition
        case stage
        case onMedication = "on_medication"
        case onLID = "on_lid"
    }
} 