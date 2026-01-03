
import SwiftUI
import VisionKit
import Vision

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognizedText: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        viewController.delegate = context.coordinator
        
        // Start scanning
        try? viewController.startScanning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Not needed for this use case
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: DataScannerView
        private var recognizedItems: [RecognizedItem] = []
        
        init(_ parent: DataScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                // Process the tapped text item
                processRecognizedText(text.transcript)
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Keep track of all recognized items
            self.recognizedItems = allItems
            processAllRecognizedItems()
        }
        
        private func processAllRecognizedItems() {
            guard let mostLikelyPageNumber = findPageNumber(from: recognizedItems) else {
                return
            }
            parent.recognizedText = mostLikelyPageNumber
            parent.dismiss()
        }

        private func processRecognizedText(_ text: String) {
            // Simple numeric filter
            if let _ = Int(text) {
                parent.recognizedText = text
                parent.dismiss()
            }
        }
        
        private func findPageNumber(from items: [RecognizedItem]) -> String? {
            var potentialPageNumbers: [(number: String, confidence: Double)] = []

            for item in items {
                guard case .text(let text) = item else { continue }
                
                let transcript = text.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Kriteria 1: Cuma Angka & Panjang Karakter
                guard let _ = Int(transcript), (1...4).contains(transcript.count) else { continue }

                // Kriteria 2: Posisi (Bawah atau Atas)
                let bounds = text.bounds
                let centerY = (bounds.topLeft.y + bounds.bottomLeft.y) / 2.0
                let isAtTop = centerY < 0.1
                let isAtBottom = centerY > 0.9

                guard isAtTop || isAtBottom else { continue }

                // Kriteria 3: Jauh dari blok teks lain (simplifikasi)
                // Kita hitung "confidence" berdasarkan seberapa jauh dari tengah (vertikal)
                let distanceFromCenter = abs(0.5 - centerY)
                let confidence = distanceFromCenter // Semakin jauh dari tengah, semakin tinggi confidence

                potentialPageNumbers.append((transcript, confidence))
            }

            // Urutkan berdasarkan confidence dan ambil yang tertinggi
            return potentialPageNumbers.sorted { $0.confidence > $1.confidence }.first?.number
        }
    }
}
