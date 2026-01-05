import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        VStack {
            TabView {
                OnboardingSlideView(
                    imageName: "book.pages.fill",
                    title: "Track Your Progress",
                    description: "Log the last page you read and visualize your reading habits with an activity heatmap."
                )

                OnboardingSlideView(
                    imageName: "magnifyingglass",
                    title: "Discover New Books",
                    description: "Find your next favorite book by searching the vast Google Books library."
                )

                OnboardingSlideView(
                    imageName: "camera.fill",
                    title: "Scan Page Numbers",
                    description: "Quickly update your progress by scanning the page number with your camera."
                )
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Get Started")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(32)
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
