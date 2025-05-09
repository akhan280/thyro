import SwiftUI

struct RAIPrecautionsCard: View {
    var body: some View {
        Text("RAI Precautions Card")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .cardStyle()
    }
}

#Preview {
    RAIPrecautionsCard()
} 