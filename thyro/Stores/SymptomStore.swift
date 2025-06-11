import Foundation
import Combine
import SwiftUI

class SymptomStore: ObservableObject {
    static let shared = SymptomStore()

    @Published var symptomHistory: [SymptomEntry] = []
    @Published var hasLoggedSymptomsToday: Bool = false

    private var localStoreKey = "symptomHistory"
    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadHistory()
        updateHasLoggedSymptomsToday() // Initial check
        
        // Optional: Listen for significant time changes to re-evaluate hasLoggedSymptomsToday
        // NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
        //     .sink { [weak self] _ in
        //         print("SymptomStore: Significant time change detected.")
        //         self?.updateHasLoggedSymptomsToday()
        //     }
        //     .store(in: &cancellables)
    }

    func addSymptomEntry(_ entry: SymptomEntry) {
        symptomHistory.insert(entry, at: 0) // Add to the beginning for chronological display (newest first)
        symptomHistory.sort(by: { $0.date > $1.date }) // Keep it sorted if inserting elsewhere
        saveHistory()
        updateHasLoggedSymptomsToday()
        
        // TODO: Integrate with Supabase if cloud sync is desired for symptoms
        // SupabaseService.shared.pushSymptomEntry(entry)
        print("SymptomStore: Added new entry. History count: \(symptomHistory.count)")
    }

    private func updateHasLoggedSymptomsToday() {
        let todayLogExists = symptomHistory.contains { entry in
            Calendar.current.isDateInToday(entry.date)
        }
        if hasLoggedSymptomsToday != todayLogExists {
            hasLoggedSymptomsToday = todayLogExists
            print("SymptomStore: hasLoggedSymptomsToday updated to: \(hasLoggedSymptomsToday)")
        }
    }

    private func saveHistory() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(symptomHistory) {
            UserDefaults.standard.set(encoded, forKey: localStoreKey)
            print("SymptomStore: History saved to UserDefaults.")
        } else {
            print("SymptomStore: Failed to save history to UserDefaults.")
        }
    }

    private func loadHistory() {
        if let savedData = UserDefaults.standard.data(forKey: localStoreKey) {
            let decoder = JSONDecoder()
            if let loadedHistory = try? decoder.decode([SymptomEntry].self, from: savedData) {
                symptomHistory = loadedHistory.sorted(by: { $0.date > $1.date })
                print("SymptomStore: History loaded from UserDefaults. Count: \(symptomHistory.count)")
                return
            }
        }
        symptomHistory = [] // Initialize to empty if no data found or decoding fails
        print("SymptomStore: No history found in UserDefaults or failed to decode.")
    }
    
    // Call this if the app comes to foreground to re-check the date against logs
    func refreshTodayLogStatus() {
        print("SymptomStore: Refreshing today's log status.")
        updateHasLoggedSymptomsToday()
    }
    
    // For Debugging/Testing
    func clearAllHistory() {
        symptomHistory = []
        saveHistory()
        updateHasLoggedSymptomsToday()
        print("SymptomStore: All symptom history cleared.")
    }
} 