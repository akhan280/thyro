import SwiftUI

struct RAIPrecautionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.title2)
                    .foregroundColor(Color.red)
                Text("RAI Safety Precautions")
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.9))
            }

            Text("Essential guidelines for your safety and others during and after treatment.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Spacer()
            
            Text("Tap to review important details")
                .font(.caption)
                .foregroundColor(Color.accentColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .topLeading) // Adjusted height for more text
        .cardStyle()
    }
}

#Preview {
    RAIPrecautionsCard()
        .padding()
        .frame(width: 350)
} 