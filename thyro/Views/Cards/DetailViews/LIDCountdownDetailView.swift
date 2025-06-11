import SwiftUI

struct LIDCountdownDetailView: View {
    @EnvironmentObject var configStore: ConfigStore
    @State private var selectedDate: Date = Date() // For the DatePicker
    @State private var showingDatePicker: Bool = false

    // This computed property correctly handles config being nil
    private var raiDate: Date? {
        configStore.config?.nextImportantDate
    }

    // This computed property correctly uses raiDate (which handles nil config)
    private var daysUntilRAI: Int? {
        guard let date = raiDate, date > Date() else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: date)).day
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let days = daysUntilRAI, let validRaiDate = raiDate { // Use validRaiDate for clarity
                    // MARK: - Set Up State
                    VStack(spacing: 10) {
                        Text("Your RAI Treatment is in")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("\(days)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(Color.purple)
                        
                        Text(days == 1 ? "Day" : "Days")
                            .font(.largeTitle)
                            .fontWeight(.medium)
                            .foregroundColor(Color.purple.opacity(0.9))
                            .offset(y: -10) // Adjust position relative to the large number
                        
                        Text("Scheduled for: \(validRaiDate, formatter: dateFormatter)")
                            .font(.headline)
                            .padding(.top, 10)
                    }
                    .padding(.vertical, 40)

                    Button("Change RAI Date") {
                        selectedDate = validRaiDate // Use the non-optional date here
                        showingDatePicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear RAI Date") {
                        guard var currentConfig = configStore.config else { return }
                        currentConfig.nextImportantDate = nil
                        configStore.setConfig(currentConfig)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                } else {
                    // MARK: - Not Set Up State
                    VStack(spacing: 15) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(Color.purple.opacity(0.7))
                        Text("Set Your RAI Date")
                            .font(.title2.bold())
                        Text("Start the countdown to your Radioiodine (RAI) treatment. This will also help tailor information for your Low Iodine Diet (LID) preparation.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 40)

                    Button("Select RAI Date") {
                        // Ensure there's a config to potentially update, even if just to set a date for the first time
                        guard configStore.config != nil else {
                            print("Error: Cannot select RAI date, user config is not loaded.")
                            // Optionally, you could attempt to create a default config if this state is reachable
                            // and user is authenticated, but that should ideally happen earlier in the flow.
                            return
                        }
                        selectedDate = configStore.config?.nextImportantDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())! 
                        showingDatePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                
                Spacer() // Pushes content up if ScrollView is not full
            }
            .padding()
        }
        .navigationTitle(raiDate == nil ? "Set LID Countdown" : "LID Countdown")
        .sheet(isPresented: $showingDatePicker) {
            VStack {
                Text("Select Your RAI Treatment Date")
                    .font(.headline)
                    .padding(.top)
                DatePicker(
                    "RAI Date",
                    selection: $selectedDate,
                    in: Date()..., // Allow selection from today onwards
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()

                HStack(spacing: 20) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save Date") {
                        guard var currentConfig = configStore.config else { 
                            print("Error: Cannot save date, user config not loaded.")
                            showingDatePicker = false
                            return
                        }
                        currentConfig.nextImportantDate = selectedDate
                        configStore.setConfig(currentConfig)
                        showingDatePicker = false
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                Spacer()
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    let configStore = ConfigStore.shared
    let previewUserID = UUID()

    // Corrected UserConfig initialization
    let sampleConfig = UserConfig(
        user_id: previewUserID, 
        logSymptoms: true, 
        trackAppointments: true, 
        manageMedications: true, 
        nextImportantDate: nil, // or Calendar.current.date(byAdding: .day, value: 10, to: Date())! for date set example
        meds: []
    )
    configStore.config = sampleConfig
    
    let journeyStore = JourneyStore.shared
    journeyStore.profile = JourneyProfile(user_id: previewUserID, condition: .cancer, stage: .raiPrep, onMedication: true, onLID: true)

    return NavigationView {
        LIDCountdownDetailView()
            .environmentObject(configStore)
            .environmentObject(journeyStore)
    }
} 
