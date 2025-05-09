import Foundation

struct Medication: Codable, Identifiable, Hashable {
    var id: UUID = .init()
    var name: String
    var doseMg: Double
    var unit: String      // "mcg", "mg", etc.
} 