import Foundation

// Represents a single symptom log entry
struct SymptomEntry: Identifiable, Codable, Hashable {
    let id: UUID // Keep UUID for local and potentially Supabase primary key
    let date: Date
    let moodScore: Int // e.g., 1-5 or 1-10
    let selectedSymptoms: [String] // Names of symptoms, keep as String array for Codable simplicity
    let notes: String?

    // Default initializer if needed elsewhere, ensuring ID is always set
    init(id: UUID = UUID(), date: Date, moodScore: Int, selectedSymptoms: [String], notes: String?) {
        self.id = id
        self.date = date
        self.moodScore = moodScore
        self.selectedSymptoms = selectedSymptoms
        self.notes = notes
    }
}

// Placeholder for common symptoms - this should be configurable or more extensive
// This could also be moved into SymptomStore or fetched from a configuration file/service.
let commonThyroidSymptoms: [String] = [
    "Fatigue", "Brain Fog", "Weight Gain", "Weight Loss", "Hair Loss", 
    "Dry Skin", "Anxiety", "Depression", "Palpitations", "Insomnia", 
    "Cold Intolerance", "Heat Intolerance", "Muscle Aches", "Constipation", "Diarrhea",
    "Irritability", "Tremors", "Increased Appetite", "Decreased Appetite", "Menstrual Changes"
] 