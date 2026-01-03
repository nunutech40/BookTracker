//
//  SearchResultRow.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct SearchResultRow: View {
    let item: GoogleBookItem
    var onSelect: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Async Image simple
            AsyncImage(url: URL(string: item.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http:", with: "https:") ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 40, height: 60)
            .cornerRadius(4)
            
            VStack(alignment: .leading) {
                Text(item.volumeInfo.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(item.volumeInfo.authors?.first ?? String(localized: "Unknown"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(String(localized: "Select"), action: onSelect)
                .buttonStyle(.bordered)
                .font(.caption)
        }
    }
}
