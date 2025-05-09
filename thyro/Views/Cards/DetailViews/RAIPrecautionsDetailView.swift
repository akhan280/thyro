import SwiftUI

struct RAIPrecautionsDetailView: View {
    @State private var isSetUp: Bool = false // In this case, isSetUp might mean acknowledged or viewed

    var body: some View {
        VStack(spacing: 20) {
            if isSetUp {
                Text("RAI Precautions - Viewed")
                    .font(.title)
                Text("Detailed RAI isolation precautions listed here.")
                Button("Mark as Not Viewed (Debug)") { isSetUp = false }
            } else {
                Text("RAI Precautions - Important Info")
                    .font(.title)
                Text("Review important precautions for RAI treatment.")
                Button("View RAI Precautions") { isSetUp = true }
                    .buttonStyle(.borderedProminent)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("RAI Precautions")
    }
}

#Preview {
    NavigationView {
        RAIPrecautionsDetailView()
    }
} 