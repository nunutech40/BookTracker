//
//  ShareCardView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 03/01/26.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct ShareCardView: View {
    let heatmapData: [Date: Int]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack {
                Text(NSLocalizedString("BOOKTRACKER", comment: ""))
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text(NSLocalizedString("My Reading Journey", comment: ""))
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Main Stats
            HStack {
                VStack {
                    Text("\(totalPagesRead())")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text(NSLocalizedString("Total Pages", comment: ""))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white)
                
                Spacer()
                
                VStack {
                    Text("\(heatmapData.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text(NSLocalizedString("Active Days", comment: ""))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                }
                .foregroundColor(.white)
            }
            .padding(.horizontal, 20)
            
            // THE GRID (KOTAK-KOTAK)
            ShareableHeatmap(data: heatmapData, months: 6)
            
            // Legend
            HStack {
                Text(NSLocalizedString("Less", comment: ""))
                RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.2)).frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 2).fill(Color.yellow.opacity(0.4)).frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 2).fill(Color.yellow.opacity(0.7)).frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 2).fill(Color.yellow).frame(width: 12, height: 12)
                Text(NSLocalizedString("More", comment: ""))
            }
            .font(.caption2)
            .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            // Footer
            HStack {
                Image(uiImage: generateQRCode(from: "https://apps.apple.com/app/idYOUR_APP_ID"))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    Text(NSLocalizedString("Track your reading habits!", comment: ""))
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(NSLocalizedString("Get BookTracker on the App Store", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding(30)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .frame(width: 400, height: 600)
        .cornerRadius(20)
        .shadow(color: .purple.opacity(0.5), radius: 20, x: 0, y: 10)
    }
    
    func totalPagesRead() -> Int {
        heatmapData.values.reduce(0, +)
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(string.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
