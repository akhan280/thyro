import SwiftUI

// Placeholder struct for a precaution item, could be expanded
struct PrecautionItem: Identifiable {
    let id = UUID()
    let title: String
    let details: String
    var isExpanded: Bool = false // For potential individual expansion if needed
}

struct PrecautionSection: Identifiable {
    let id = UUID()
    let title: String
    let symbolName: String
    let items: [PrecautionItem]
    var isInitiallyExpanded: Bool = false
}

struct RAIPrecautionsDetailView: View {
    // Data for the sections - REPLACE with accurate medical information
    // This data should ideally come from a reliable source or be configurable.
    private let precautionSections: [PrecautionSection] = [
        PrecautionSection(title: "Understanding RAI Safety", symbolName: "info.circle.fill", items: [
            PrecautionItem(title: "Why Precautions?", details: "Radioactive iodine (RAI) temporarily makes your body fluids (like saliva, sweat, urine, and stool) radioactive. These precautions protect others from unnecessary radiation exposure."),
            PrecautionItem(title: "Key Principles", details: "Minimize time spent near others, maximize distance, and practice meticulous hygiene to prevent contamination.")
        ], isInitiallyExpanded: true),
        PrecautionSection(title: "During Your Isolation Period", symbolName: "house.fill", items: [
            PrecautionItem(title: "Personal Hygiene", details: "Wash hands frequently with soap and water, especially after using the toilet and before preparing food. Flush the toilet 2-3 times after each use. Use separate towels."),
            PrecautionItem(title: "Laundry & Linens", details: "Wash your clothing, towels, and bed linens separately from others in your household. Run an empty rinse cycle after."),
            PrecautionItem(title: "Dishes & Utensils", details: "Use disposable plates and utensils if possible. If not, wash your used items separately with hot water and soap."),
            PrecautionItem(title: "Waste Disposal", details: "Your medical team will provide instructions for disposing of any contaminated waste (e.g., tissues, disposable items). Often, it's double-bagged and stored separately for a period."),
            PrecautionItem(title: "Contact with Others", details: "Maintain significant distance (e.g., 6 feet or more) from others. Avoid close or prolonged contact, especially with children, pregnant women, and pets. No kissing or sexual contact."),
            PrecautionItem(title: "Sleeping Arrangements", details: "Sleep in a separate bed, and ideally a separate room, from others."),
            PrecautionItem(title: "Duration of Precautions", details: "Your doctor will tell you exactly how long these precautions are necessary, typically ranging from a few days to a week or more depending on the dose.")
        ], isInitiallyExpanded: true),
        PrecautionSection(title: "After Your Isolation Period", symbolName: "figure.walk", items: [
            PrecautionItem(title: "Gradual Return", details: "Follow your doctor's advice on resuming normal activities and contact with others. Some minor precautions might continue for a short while.")
        ]),
        PrecautionSection(title: "When to Call Your Doctor", symbolName: "phone.fill.badge.plus", items: [
            PrecautionItem(title: "Urgent Concerns", details: "Contact your doctor immediately if you experience severe nausea, vomiting, neck swelling or pain, or any other concerning symptoms after your RAI treatment.")
        ])
    ]

    // State to manage expansion of each section by its ID
    @State private var expansionState: [UUID: Bool] = [:]

    init() {
        // Initialize expansionState based on isInitiallyExpanded
        var initialState: [UUID: Bool] = [:]
        for section in precautionSections {
            initialState[section.id] = section.isInitiallyExpanded
        }
        _expansionState = State(initialValue: initialState)
    }

    private func bindingForSection(_ sectionID: UUID) -> Binding<Bool> {
        return Binding(get: { self.expansionState[sectionID, default: false] },
                       set: { self.expansionState[sectionID] = $0 })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled.badge.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        Text("RAI Safety Precautions")
                            .font(.largeTitle.bold())
                    }
                    Text("Following these guidelines is crucial for the safety of yourself and those around you after receiving Radioiodine (RAI) therapy. Always adhere to the specific instructions provided by your medical team.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)

                // Precaution Sections
                ForEach(precautionSections) { section in
                    DisclosureGroup(
                        isExpanded: bindingForSection(section.id), // Use the binding
                        content: {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(section.items) { item in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.headline.weight(.semibold))
                                        Text(item.details)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    }
                                    if item.id != section.items.last?.id { // Add divider if not the last item
                                        Divider().padding(.vertical, 5)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        },
                        label: {
                            HStack {
                                Image(systemName: section.symbolName)
                                    .foregroundColor(Color.accentColor)
                                Text(section.title)
                                    .font(.title3.weight(.medium))
                                    .foregroundColor(.primary)
                            }
                        }
                    )
                    .padding(.vertical, 5)
                    Divider()
                }
                
                // Final Disclaimer
                VStack(alignment: .center, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("This information is for general guidance only. Your doctor's instructions supersede any information provided here. Consult your medical team for personalized advice.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

            }
            .padding()
        }
        .navigationTitle("RAI Precautions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        RAIPrecautionsDetailView()
    }
} 