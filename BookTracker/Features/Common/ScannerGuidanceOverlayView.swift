import SwiftUI

struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

struct ScannerGuidanceOverlayView: View {
    var onCancel: () -> Void
    @Binding var showNotFound: Bool
    
    var body: some View {
        VStack {
            // Top Bar with instructions and cancel button
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(NSLocalizedString("Point camera at page number. Scanning is automatic.", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.white)

                    Text(NSLocalizedString("Keep camera steady for best results.", comment: ""))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(12)
                .background(Color.black.opacity(0.6))
                .cornerRadius(10)
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .shadow(radius: 3)
                }
            }
            .padding()
            
            Spacer()
            
            // Viewfinder (visual guide only)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 3, dash: [15, 10]))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 300, height: 150)
                    .modifier(Shake(animatableData: showNotFound ? 1 : 0))

                if showNotFound {
                    Text(NSLocalizedString("Page number not found. Please try again.", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            
            Spacer()
        }
        .onChange(of: showNotFound) {
            if showNotFound {
                // Reset the state after the animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        self.showNotFound = false
                    }
                }
            }
        }
    }
}
