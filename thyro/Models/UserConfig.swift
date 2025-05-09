import Foundation

struct UserConfig: Identifiable, Codable {
    var id: UUID = .init()
    var trackSymptoms: Bool
    var labReminders: Bool
    var nextImportantDate: Date?
    var meds: [Medication]
} 