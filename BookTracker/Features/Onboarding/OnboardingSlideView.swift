import SwiftUI

struct OnboardingSlideView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // --- Poles Screenshot biar kayak Mockup ---
            Image(imageName)
                .resizable()
                .scaledToFit()
                .cornerRadius(24) // Bikin sudut tumpul ala iPhone
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1) // Garis pinggir halus
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10) // Shadow buat efek depth
                .padding(.horizontal, 50) // Biar nggak mepet layar
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
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
