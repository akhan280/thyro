import SwiftUI

struct LIDCountdownDetailView: View {
    @EnvironmentObject var configStore: ConfigStore
    @State private var selectedDate: Date = Date() // For the DatePicker
    @State private var showingDatePicker: Bool = false

    private var raiDate: Date? {
        configStore.config.nextImportantDate
    }

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
                if let days = daysUntilRAI, let date = raiDate {
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
                        
                        Text("Scheduled for: \(date, formatter: dateFormatter)")
                            .font(.headline)
                            .padding(.top, 10)
                    }
                    .padding(.vertical, 40)

                    Button("Change RAI Date") {
                        selectedDate = raiDate ?? Date() // Initialize picker with current date or today
                        showingDatePicker = true
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Clear RAI Date") {
                        var updatedConfig = configStore.config
                        updatedConfig.nextImportantDate = nil
                        configStore.setConfig(updatedConfig)
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
                        selectedDate = configStore.config.nextImportantDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())! // Default to tomorrow
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
                        var updatedConfig = configStore.config
                        updatedConfig.nextImportantDate = selectedDate
                        configStore.setConfig(updatedConfig)
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
    // Example 1: Date set
    // configStore.config = UserConfig(trackSymptoms: true, labReminders: true, nextImportantDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, meds: [])
    // Example 2: No date set
    configStore.config = UserConfig(trackSymptoms: true, labReminders: true, nextImportantDate: nil, meds: [])
    
    return NavigationView {
        LIDCountdownDetailView()
            .environmentObject(configStore)
    }
} 