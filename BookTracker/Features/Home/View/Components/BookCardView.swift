//
//  NativeBookRow.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct BookCardView: View {
    // MARK: - Properties
    let book: Book
    var onTapUpdate: () -> Void
    var onTapCamera: () -> Void
    
    // MARK: - Main Body (Abstraction)
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            bookCoverSection
            bookInfoSection
            actionButtonsSection
        }
        .padding(12) // Padding internal
        .background(Color(uiColor: .secondarySystemGroupedBackground)) // Warna kartu native modern
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4) // Soft shadow
    }
}

// MARK: - Component Builders
private extension BookCardView {
    
    // 1. Cover Image Logic
    @ViewBuilder
    var bookCoverSection: some View {
        if let data = book.coverImageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 75)
                .cornerRadius(6)
        } else {
            placeholderCover
        }
    }
    
    var placeholderCover: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 50, height: 75)
            .overlay(
                Image(systemName: "book")
                    .foregroundStyle(.secondary)
            )
    }
    
    // 2. Info (Title & Progress)
    var bookInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(book.title)
                .font(.headline)
                .lineLimit(1)
            
            ProgressView(value: Double(book.currentPage), total: Double(book.totalPages))
                .progressViewStyle(.linear)
                .tint(.blue)
            
            Text(String(format: NSLocalizedString("%d / %d pages", comment: ""), book.currentPage, book.totalPages))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // 3. Action Buttons
    var actionButtonsSection: some View {
        HStack(spacing: 8) {
            pageInputButton
            cameraButton
        }
    }
    
    var pageInputButton: some View {
        Button(action: onTapUpdate) {
            Text("\(book.currentPage)")
                .font(.system(.subheadline, design: .monospaced))
                .bold()
                .frame(minWidth: 32)
        }
        .buttonStyle(.bordered)
        .tint(.primary)
    }
    
    var cameraButton: some View {
        Button(action: onTapCamera) {
            Image(systemName: "camera")
        }
        .buttonStyle(.bordered)
    }
}
