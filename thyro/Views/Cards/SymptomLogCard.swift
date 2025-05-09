import SwiftUI

struct SymptomLogCard: View {
    var body: some View {
        Text("Symptom Log Card")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .cardStyle()
    }
}

#Preview {
    SymptomLogCard()
} 