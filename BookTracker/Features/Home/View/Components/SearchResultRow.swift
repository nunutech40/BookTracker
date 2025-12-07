//
//  SearchResultRow.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct SearchResultRow: View {
    let item: GoogleBookItem
    var onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Cover Image (AsyncImage karena ini dari URL internet)
            AsyncImage(url: URL(string: item.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http:", with: "https:") ?? "")) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(Image(systemName: "book").foregroundStyle(.secondary))
                }
            }
            .frame(width: 50, height: 75)
            .cornerRadius(8)
            
            // 2. Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.volumeInfo.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let authors = item.volumeInfo.authors {
                    Text(authors.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 3. Add Button
            Button(action: onAdd) {
                Text("ADD")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .cornerRadius(20)
            }
        }
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(12)
        // Shadow tipis biar pop
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
