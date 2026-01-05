//
//  LibraryBookView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//
//
//  LibraryBookRow.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct LibraryBookRow: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. Cover Image
            if let data = book.coverImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 70)
                    .cornerRadius(6)
                    .shadow(radius: 2)
            } else {
                // Placeholder kalau gak ada cover
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 45, height: 70)
                    .overlay(
                        Image(systemName: "book.closed")
                            .foregroundStyle(.secondary)
                    )
            }
            
            // 2. Info Buku
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(book.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // LOGIC: Cuma bedain Reading vs Shelf
                if book.status == .reading {
                    // Kalau Reading: Tampilkan Progress
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.caption2)
                        Text(String(format: NSLocalizedString("%d / %d Pages", comment: ""), book.currentPage, book.totalPages))
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                    .padding(.top, 2)
                } else {
                    // Kalau Shelf (atau default): Tampilkan Total Pages aja
                    Text(String(format: NSLocalizedString("%d Pages", comment: ""), book.totalPages))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
