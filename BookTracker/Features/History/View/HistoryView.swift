//
//  HistoryView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    
    // 1. Ambil semua buku dulu (biar aman dari error Enum Predicate)
    @Query(sort: \Book.lastInteraction, order: .reverse) private var allBooks: [Book]
    
    // 2. Filter manual di sini (Cuma ambil yang Finished)
    var finishedBooks: [Book] {
        return allBooks.filter { $0.status == .finished }
    }
    
    var body: some View {
        Group {
            if finishedBooks.isEmpty {
                ContentUnavailableView(
                    String(localized: "No Finished Books"),
                    systemImage: "trophy",
                    description: Text(String(localized: "Finish a book to see it here."))
                )
            } else {
                List {
                    ForEach(finishedBooks) { book in
                        // Bisa diklik buat liat detail/edit lagi
                        NavigationLink(destination: BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel(book: book))) {
                            LibraryBookRow(book: book) // Reuse row yang udah ada
                        }
                        // Tetep bisa dihapus kalau mau
                        .swipeActions(edge: .trailing) {
                            Button(String(localized: "Delete"), systemImage: "trash", role: .destructive) {
                                context.delete(book)
                            }
                        }
                        // Bisa baca ulang (Pindah ke Reading)
                        .swipeActions(edge: .leading) {
                            Button(String(localized: "Read Again"), systemImage: "arrow.clockwise") {
                                moveToReading(book)
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(String(localized: "Finished Books"))
    }
    
    // MARK: - Actions
    
    func moveToReading(_ book: Book) {
        withAnimation {
            book.status = .reading
            book.currentPage = 0 // Reset halaman ke 0 kalau mau baca ulang dari awal
            book.lastInteraction = Date()
        }
    }
}
