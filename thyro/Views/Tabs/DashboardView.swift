import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var configStore: ConfigStore
    @EnvironmentObject var journeyStore: JourneyStore // Added for debug info

    var body: some View {
        NavigationView { 
            ScrollView {
                // MARK: - Debug Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Debug Info:")
                        .font(.caption.weight(.bold))
                        .padding(.bottom, 5)
                    
                    DisclosureGroup("Journey Profile") {
                        Text(String(describing: journeyStore.profile))
                            .font(.system(size: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 5)
                    }
                    .font(.caption)
                    
                    DisclosureGroup("Enabled Cards (\(configStore.cards.count))") {
                        ForEach(configStore.cards) { card in
                            Text("- \(card.type.rawValue)")
                                .font(.system(size: 10))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                    }
                    .font(.caption)
                }
                .padding()
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal)
                // END: Debug Information
                
                LazyVStack(spacing: 16) {
                    if configStore.cards.isEmpty {
                        Text("No cards to display based on your current profile and settings.")
                            .padding()
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(configStore.cards) { cardDescriptor in
                            NavigationLink(destination: destinationView(for: cardDescriptor.type)) {
                                CardFactory.make(for: cardDescriptor.type)
                                    .contentShape(Rectangle()) // Ensure the whole card area is tappable
                            }
                            .buttonStyle(PlainButtonStyle()) // To prevent default NavLink styling on the card content
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }

    @ViewBuilder
    private func destinationView(for cardType: CardType) -> some View {
        switch cardType {
        case .symptomLog:
            SymptomLogDetailView()
        case .medicationReminder:
            MedicationReminderDetailView()
        case .lidCountdown:
            LIDCountdownDetailView()
        case .raiPrecautions:
            RAIPrecautionsDetailView()
        case .tgTrend:
            TgTrendDetailView()
        case .heartRateLog:
            HeartRateLogDetailView()
        case .appointments:
            AppointmentsDetailView()
        }
    }
}

#Preview {
    // For DashboardView preview, ensure all necessary stores are provided, especially if cards use them.
    let configStore = ConfigStore.shared
    let journeyStore = JourneyStore.shared
    let appointmentStore = AppointmentStore.shared // Added for AppointmentsCard
    let symptomStore = SymptomStore.shared     // Added for SymptomLogCard if its preview implies it
    let previewUserID = UUID()

    // Setup a basic profile and config for the preview to make sense
    journeyStore.profile = JourneyProfile(user_id: previewUserID, condition: .hypo, stage: .surveillance, onMedication: true, onLID: false)
    configStore.config = UserConfig(user_id: previewUserID, logSymptoms: true, trackAppointments: true, manageMedications: true)
    // You might want to add a sample appointment for the AppointmentsCard preview
    // appointmentStore.addAppointment(Appointment(title: "Preview Appointment", date: Date()))

    return DashboardView()
        .environmentObject(configStore)
        .environmentObject(journeyStore)
        .environmentObject(appointmentStore) // Inject AppointmentStore
        .environmentObject(symptomStore)     // Inject SymptomStore
} 
