import SwiftUI
import VisionKit
import Vision

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Environment(\.dismiss) var dismiss
    @State private var showNotFound = false
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        viewController.delegate = context.coordinator
        context.coordinator.viewController = viewController
        
        // Add the overlay
        let overlay = UIHostingController(rootView: ScannerGuidanceOverlayView(
            onCancel: {
                dismiss()
            },
            showNotFound: $showNotFound
        ))
        overlay.view.backgroundColor = .clear
        overlay.view.frame = viewController.view.bounds
        overlay.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.addChild(overlay)
        viewController.view.addSubview(overlay.view)
        
        try? viewController.startScanning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        var viewController: DataScannerViewController?
        private var recognizedItems: [RecognizedItem] = []
        private var debounceTimer: Timer?
        private let feedbackGenerator = UINotificationFeedbackGenerator()

        init(_ parent: DataScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = allItems
            debounceTimer?.invalidate()
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] _ in
                self?.processAllRecognizedItems()
            }
        }
        
        private func processAllRecognizedItems() {
            if let mostLikelyPageNumber = findPageNumber(from: recognizedItems) {
                parent.recognizedText = mostLikelyPageNumber
                feedbackGenerator.notificationOccurred(.success)
                parent.dismiss()
            } else {
                // If no number is found, trigger feedback and keep scanning
                feedbackGenerator.notificationOccurred(.error)
                withAnimation {
                    parent.showNotFound = true
                }
            }
        }
        
        private func findPageNumber(from items: [RecognizedItem]) -> String? {
            var potentialPageNumbers: [(number: String, confidence: Double)] = []

            for item in items {
                guard case .text(let text) = item else { continue }
                
                let transcript = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let _ = Int(transcript), (1...4).contains(transcript.count) else { continue }

                let bounds = text.bounds
                let centerY = (bounds.topLeft.y + bounds.bottomLeft.y) / 2.0
                let isAtTop = centerY < 0.20 // Widen the area a bit more
                let isAtBottom = centerY > 0.80 // Widen the area a bit more

                guard isAtTop || isAtBottom else { continue }

                let confidence = abs(0.5 - centerY)
                potentialPageNumbers.append((transcript, confidence))
            }

            return potentialPageNumbers.sorted { $0.confidence > $1.confidence }.first?.number
        }
    }
}
