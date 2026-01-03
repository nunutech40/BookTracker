//
//  LibraryView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    
    // Default Filter: Shelf
    @State private var selectedTab: BookStatus = .shelf
    
    // Ambil SEMUA buku (Tanpa filter di query biar kita bisa debug)
    @Query(sort: \Book.lastInteraction, order: .reverse) private var allBooks: [Book]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 1. Filter Tab
                Picker("Filter", selection: $selectedTab) {
                    Text(String(localized: "To Read (Shelf)")).tag(BookStatus.shelf)
                    Text(String(localized: "Reading Now")).tag(BookStatus.reading)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 3. Content List
                if currentBooks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(currentBooks) { book in
                            bookRow(for: book)
                        }
                        .onDelete(perform: deleteBooks)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "My Library"))
            // Tombol ke History
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                    }
                }
            }
        }
    }
    
    // MARK: - Logic Filter Langsung
    // Kita pindahin logic filter ke sini biar lebih reaktif
    var currentBooks: [Book] {
        return allBooks.filter { book in
            return book.status == selectedTab
        }
    }
    
    // MARK: - Builders & Actions
    
    @MainActor
    func bookRow(for book: Book) -> some View {
        NavigationLink(destination: BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel(book: book))) {
            LibraryBookRow(book: book)
        }
        .swipeActions(edge: .leading) {
            if book.status == .shelf {
                Button(String(localized: "Read")) { moveToReading(book) }.tint(.blue)
            } else {
                Button(String(localized: "Shelf")) { moveToShelf(book) }.tint(.orange)
            }
        }
    }
    
    var emptyStateView: some View {
        let title = selectedTab == .shelf ? String(localized: "Shelf Empty") : String(localized: "No Active Reading")
        let description = selectedTab == .shelf ? String(localized: "Add new books to your queue.") : String(localized: "Start reading books from your shelf.")
        
        return ContentUnavailableView(
            title,
            systemImage: selectedTab == .shelf ? "books.vertical" : "book.closed",
            description: Text(description)
        )
    }
    
    func moveToReading(_ book: Book) {
        withAnimation {
            book.status = .reading
            book.lastInteraction = Date()
        }
    }
    
    func moveToShelf(_ book: Book) {
        withAnimation { book.status = .shelf }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            let book = currentBooks[index]
            context.delete(book)
        }
    }
}
