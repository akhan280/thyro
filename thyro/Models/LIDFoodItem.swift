import Foundation
import SwiftUI // Required for Color in LIDCompliance

// Enum for LID Compliance Status
enum LIDCompliance: String, Codable, CaseIterable, Hashable {
    case compliant = "Compliant"
    case nonCompliant = "Non-Compliant"
    case checkIngredients = "Check Ingredients" // e.g., for items where some brands are okay
    case variable = "Variable" // e.g., restaurant item, depends on preparation
    case unknown = "Unknown"

    var iconName: String {
        switch self {
        case .compliant: return "checkmark.circle.fill"
        case .nonCompliant: return "xmark.circle.fill"
        case .checkIngredients: return "questionmark.circle.fill"
        case .variable: return "exclamationmark.triangle.fill"
        case .unknown: return "questionmark.diamond.fill"
        }
    }
    var iconColor: Color { // Assuming SwiftUI.Color
        switch self {
        case .compliant: return .green
        case .nonCompliant: return .red
        case .checkIngredients: return .orange
        case .variable: return .yellow // Consider a distinct color like .blue if yellow is too close to orange
        case .unknown: return .gray
        }
    }
}

// Enum for broad categories used for filtering pills
enum LIDFoodParentCategory: String, Codable, CaseIterable, Hashable {
    case restaurant = "Restaurants"
    case food = "Foods" // This will be the parent for more specific food types
    case ingredient = "Ingredients"
}

// Main Data Structure for Food Items
struct LIDFoodItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID() // Default for new items, Supabase might provide its own
    var name: String
    var parentCategory: LIDFoodParentCategory
    var subCategory: String? // e.g., "Fruits", "Vegetables", "Fast Food", "Salt Types"
    var brand: String?
    var compliance: LIDCompliance
    var notes: String?
    var servingSize: String?
    var iodineContentEstimate: String?
    var dataSource: String?
    var lastVerifiedDate: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, brand, notes, compliance // Properties with matching names
        case parentCategory = "parent_category"
        case subCategory = "sub_category"
        case servingSize = "serving_size"
        case iodineContentEstimate = "iodine_content_estimate"
        case dataSource = "data_source"
        case lastVerifiedDate = "last_verified_date"
    }
} 