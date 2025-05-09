import SwiftUI

struct ConditionPickerView: View {
    @Binding var selectedCondition: Condition?
    var onNext: () -> Void

    private let conditions = Condition.allCases
    private let backgroundColor = Color(red: 248/255, green: 248/255, blue: 247/255) // Off-white/beige
    private let buttonBackgroundColor = Color.white
    private let selectedButtonColor = Color.purple.opacity(0.1)
    private let textColor = Color.black.opacity(0.8)

    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                // Onboarding Step Icons
                HStack(spacing: 12) {
                    OnboardingStepIcon(systemName: "heart.text.square", isSelected: true)
                    OnboardingStepIcon(systemName: "clock", isSelected: false)
                    OnboardingStepIcon(systemName: "pills", isSelected: false)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                Text("What brings you to Thyro?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
                    .padding(.bottom, 30)

                VStack(spacing: 15) {
                    ForEach(conditions, id: \.self) { condition in
                        ConditionButton(condition: condition, 
                                        selectedCondition: $selectedCondition,
                                        backgroundColor: buttonBackgroundColor,
                                        selectedColor: selectedButtonColor,
                                        textColor: textColor
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Next Button
                Button(action: onNext) {
                    Text("Next")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                        .opacity(selectedCondition == nil ? 0.5 : 1.0)
                }
                .disabled(selectedCondition == nil)
                .padding(.horizontal, 40)
                .padding(.bottom, 10)

                Text("Your data is stored locally")
                    .font(.caption)
                    .foregroundColor(textColor.opacity(0.6))
                    .padding(.bottom, 20)
            }
        }
        // .navigationTitle("Condition") // Title is now part of the view content
        .navigationBarHidden(true) // Assuming a custom navigation or it's part of a larger NavStack
    }
}

struct OnboardingStepIcon: View {
    let systemName: String
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18))
            .foregroundColor(isSelected ? Color.purple : Color.gray.opacity(0.5))
            .frame(width: 44, height: 44)
            .background(isSelected ? Color.purple.opacity(0.1) : Color.gray.opacity(0.1))
            .clipShape(Circle())
    }
}

struct ConditionButton: View {
    let condition: Condition
    @Binding var selectedCondition: Condition?
    let backgroundColor: Color
    let selectedColor: Color
    let textColor: Color

    var isSelected: Bool {
        selectedCondition == condition
    }

    var body: some View {
        Button(action: {
            selectedCondition = condition
        }) {
            Text(condition.rawValue.capitalized)
                .font(.headline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(textColor)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isSelected ? selectedColor : backgroundColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.purple : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                )
        }
    }
}


#Preview {
    // Use a local state for the preview binding
    struct PreviewWrapper: View {
        @State var condition: Condition? = nil
        var body: some View {
            NavigationView { // Keep NavigationView for preview context if subviews expect it
                ConditionPickerView(selectedCondition: $condition, onNext: { print("Next tapped. Selected: \(String(describing: condition))" ) })
            }
        }
    }
    return PreviewWrapper()
} 