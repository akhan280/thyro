import SwiftUI

// SymptomEntry and commonThyroidSymptoms are now in Models/SymptomData.swift

struct SymptomLogDetailView: View {
    @StateObject private var symptomStore = SymptomStore.shared // Use the shared instance
    
    @State private var showingLogSheet = false
    
    // States for the new log sheet (could also be part of SymptomLoggingSheetView itself if not needed here)
    @State private var currentMoodScore: Double = 3 
    @State private var currentSelectedSymptoms = Set<String>()
    @State private var currentNotes: String = ""

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        List {
            Section(header: Text("Log New Symptoms")) {
                Button(action: { 
                    // Reset sheet state before showing
                    currentMoodScore = 3
                    currentSelectedSymptoms = Set<String>()
                    currentNotes = ""
                    showingLogSheet = true 
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Today's Symptom Log")
                    }
                    .font(.headline)
                }
            }

            Section(header: Text("Symptom History")) {
                if symptomStore.symptomHistory.isEmpty {
                    Text("No symptoms logged yet. Tap above to add your first log.")
                        .foregroundColor(.secondary)
                        .padding(.vertical)
                } else {
                    // History is already sorted in SymptomStore
                    ForEach(symptomStore.symptomHistory) { entry in 
                        VStack(alignment: .leading, spacing: 8) {
                            Text(entry.date, formatter: dateFormatter)
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack {
                                Text("Mood: \(entry.moodScore)/5") 
                                    .font(.subheadline.weight(.semibold))
                            }
                            if !entry.selectedSymptoms.isEmpty {
                                Text("Symptoms: \(entry.selectedSymptoms.joined(separator: ", "))")
                                    .font(.subheadline)
                            }
                            if let notes = entry.notes, !notes.isEmpty {
                                Text("Notes: \(notes)")
                                    .font(.footnote)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("Symptom Log")
        .sheet(isPresented: $showingLogSheet) {
            NavigationView { 
                SymptomLoggingSheetView(
                    moodScore: $currentMoodScore, 
                    selectedSymptoms: $currentSelectedSymptoms, 
                    notes: $currentNotes,
                    onSave: {
                        let newEntry = SymptomEntry(
                            // id: UUID() is handled by default initializer
                            date: Date(), 
                            moodScore: Int(currentMoodScore.rounded()), 
                            selectedSymptoms: Array(currentSelectedSymptoms), 
                            notes: currentNotes.isEmpty ? nil : currentNotes
                        )
                        symptomStore.addSymptomEntry(newEntry)
                        showingLogSheet = false
                        // Sheet states are reset when sheet is presented now
                    },
                    onCancel: {
                        showingLogSheet = false
                        // Sheet states are reset when sheet is presented now
                    }
                )
            }
        }
        .onAppear {
            symptomStore.refreshTodayLogStatus() // Refresh when view appears
        }
    }
}

struct SymptomLoggingSheetView: View {
    @Binding var moodScore: Double
    @Binding var selectedSymptoms: Set<String>
    @Binding var notes: String
    
    var onSave: () -> Void
    var onCancel: () -> Void
    
    // commonThyroidSymptoms is now a global constant from SymptomData.swift
    // let allSymptoms = commonThyroidSymptoms 

    var body: some View {
        Form {
            Section(header: Text("How are you feeling overall?")) {
                VStack {
                    Text("Mood: \(Int(moodScore.rounded()))/5")
                    Slider(value: $moodScore, in: 1...5, step: 1)
                    HStack {
                        Text("Not Great")
                        Spacer()
                        Text("Great")
                    }.font(.caption).foregroundColor(.gray)
                }
                .padding(.vertical)
            }
            
            Section(header: Text("Select Symptoms (Optional)")) {
                List {
                    ForEach(commonThyroidSymptoms, id: \.self) { symptom in // Use global constant
                        Button(action: {
                            if selectedSymptoms.contains(symptom) {
                                selectedSymptoms.remove(symptom)
                            } else {
                                selectedSymptoms.insert(symptom)
                            }
                        }) {
                            HStack {
                                Text(symptom)
                                Spacer()
                                if selectedSymptoms.contains(symptom) {
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary) 
                    }
                }
                // Dynamic height for the list of symptoms, up to a certain max
                .frame(minHeight: CGFloat(commonThyroidSymptoms.count / 2) * 44.0, maxHeight: 300) 
            }
            
            Section(header: Text("Notes (Optional)")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    ) // Added a subtle border
            }
        }
        .navigationTitle("Log Symptoms - \(Date(), style: .date)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancel)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: onSave).disabled(moodScore < 1) // Example: disable save if mood not set
            }
        }
    }
}

#Preview {
    NavigationView {
        SymptomLogDetailView()
            .environmentObject(SymptomStore.shared) // Ensure store is in environment for preview if subviews need it
    }
} 