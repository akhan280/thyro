import SwiftUI

struct LIDCountdownCard: View {
    var body: some View {
        Text("LID Countdown Card")
            .padding()
            .frame(maxWidth: .infinity, minHeight: 100)
            .cardStyle()
    }
}

#Preview {
    LIDCountdownCard()
} 