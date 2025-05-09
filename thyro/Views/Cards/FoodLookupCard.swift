import SwiftUI

struct FoodLookupCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass.circle.fill") // Icon suggestion
                    .font(.title3)
                    .foregroundColor(Color.orange)
                Text("LID Food Lookup")
                    .font(.headline)
                    .foregroundColor(.primary.opacity(0.8))
            }

            Text("Check restaurants, ingredients, and foods for LID compliance.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            Text("Tap to search")
                .font(.caption)
                .foregroundColor(Color.accentColor)

        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    FoodLookupCard()
        .padding()
} 