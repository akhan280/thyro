import SwiftUI

struct WelcomeView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            // Background Gradient (Placeholder for your image)
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.pink.opacity(0.6), Color.blue.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()

                // Logo (Placeholder)
                Image("thyro_logo_white") // Replace with your actual logo if available
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.white) // Tint if it's a template image
                    
                Text("Thyro")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 15) {
                    IconPill(systemName: "heart.text.square", text: "Condition") // SFSymbol for ribbon/profile idea
                    IconPill(systemName: "clock", text: "Journey")
                    IconPill(systemName: "pills", text: "Meds")
                }
                .padding(.top, 5)

                Text("Track your thyroid journey with clarity and care.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                Spacer()


                Button(action: onGetStarted) {
                    Text("Get Started")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.purple.opacity(0.8)) // Adapting text color for white button
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.horizontal, 40)
                }

                Text("Your data is stored locally")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 20) // Pushed to the bottom
            }
            .padding(.bottom, 30) // Overall bottom padding for content
        }
    }
}

struct IconPill: View {
    let systemName: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.white)
            // Text(text) // Text removed to match design more closely to the initial image
            //     .font(.caption)
            //     .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
    }
}

#Preview {
    WelcomeView(onGetStarted: { print("Get Started Tapped") })
} 