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

struct JourneyProfile: Identifiable, Codable {
    var id: UUID = .init()
    var condition: Condition
    var stage: Stage
    var onMedication: Bool
    var onLID: Bool
} 