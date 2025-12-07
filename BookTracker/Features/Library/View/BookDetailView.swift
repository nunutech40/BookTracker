//
//  BookDetailView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct BookDetailView: View {
    @Bindable var book: Book // Bindable biar bisa edit langsung
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 1. Big Cover
                if let data = book.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                
                // 2. Info text
                VStack(spacing: 8) {
                    Text(book.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("\(book.totalPages) Pages")
                        .foregroundStyle(.secondary)
                }
                
                // 3. Status Badge (Optional)
                statusBadge
                
                Divider()
                
                // 4. ACTION BUTTON (Logic Mindahin Buku)
                actionButton
                
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Logic tampilan tombol berdasarkan status buku
    @ViewBuilder
    var actionButton: some View {
        switch book.status {
        case .shelf:
            Button(action: {
                book.status = .reading
                book.lastInteraction = Date()
                dismiss() // Balik ke list
            }) {
                Label("Start Reading", systemImage: "book.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
        case .reading:
            Button(action: {
                book.status = .finished
                book.currentPage = book.totalPages // Auto max pages
                dismiss()
            }) {
                Label("Mark as Finished", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.green)
            .controlSize(.large)
            
        case .finished:
            Button(action: {
                book.status = .reading
                book.currentPage = 0 // Reset ulang
                book.lastInteraction = Date()
                dismiss()
            }) {
                Label("Read Again", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
        }
    }
    
    var statusBadge: some View {
        Text(book.status.rawValue.uppercased())
            .font(.caption)
            .fontWeight(.bold)
            .padding(6)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(4)
    }
}
