import SwiftUI

struct OnboardingView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var selection = 0
    
    var isFromTutorial: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                OnboardingSlideView(
                    imageName: "OnBoarding1",
                    title: NSLocalizedString("Track Your Progress", comment: ""),
                    description: NSLocalizedString("Log the last page you read and visualize your reading habits with an activity heatmap.", comment: "")
                )
                .tag(0)

                OnboardingSlideView(
                    imageName: "OnBoarding2",
                    title: NSLocalizedString("Discover New Books", comment: ""),
                    description: NSLocalizedString("Find your next favorite book by searching the vast Google Books library.", comment: "")
                )
                .tag(1)

                OnboardingSlideView(
                    imageName: "OnBoarding3",
                    title: NSLocalizedString("Analyze Productivity", comment: ""),
                    description: NSLocalizedString("Monitor your reading speed and maintain your daily reading streaks.", comment: "")
                )
                .tag(2)

                OnboardingSlideView(
                    imageName: "OnBoarding4",
                    title: NSLocalizedString("Unlock Your Achievements", comment: ""),
                    description: NSLocalizedString("Stay motivated by earning medals and reaching milestones as you build your consistent reading habit.", comment: "")
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button(action: {
                if selection < 3 {
                    withAnimation { selection += 1 }
                } else {
                    if isFromTutorial {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        hasCompletedOnboarding = true
                    }
                }
            }) {
                Text(selection == 3 ? (isFromTutorial ? NSLocalizedString("Close", comment: "") : NSLocalizedString("Get Started", comment: "")) : NSLocalizedString("Next", comment: ""))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemBackground))
    }
}
