import SwiftUI

struct OnboardingSlideView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    OnboardingSlideView(
        imageName: "book.pages",
        title: "Track Your Reading",
        description: "Easily log the last page you read and monitor your progress over time."
    )
}
