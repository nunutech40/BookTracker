//
//  LibraryView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//
import SwiftUI
import SwiftData

struct LibraryView: View {
    // MARK: - Dependencies
    @Environment(\.modelContext) private var context
    
    // MARK: - State
    // 0 = Shelf, 1 = Finished
    @State private var selectedFilter: Int = 0
    
    // Query Dasar (Diurutkan berdasarkan interaksi terakhir)
    @Query(sort: \Book.lastInteraction, order: .reverse) private var allBooks: [Book]
    
    // MARK: - Main Body (Abstraction)
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterSegmentSection
                contentAreaSection
            }
            .navigationTitle("My Library")
        }
    }
}

// MARK: - View Builders & Helpers
private extension LibraryView {
    
    // 1. Logic Filtering Data
    var filteredBooks: [Book] {
        let targetStatus: BookStatus = (selectedFilter == 0) ? .shelf : .finished
        return allBooks.filter { $0.status == targetStatus }
    }
    
    // 2. Filter UI (Segmented Control)
    var filterSegmentSection: some View {
        Picker("Filter", selection: $selectedFilter) {
            Text("To Read").tag(0)
            Text("Finished").tag(1)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    // 3. Content Area (Switching List vs Empty State)
    @ViewBuilder
    var contentAreaSection: some View {
        if filteredBooks.isEmpty {
            emptyStateView
        } else {
            bookListView
        }
    }
    
    // 4. List View
    var bookListView: some View {
        List {
            ForEach(filteredBooks) { book in
                bookRow(for: book)
            }
            .onDelete(perform: deleteBooks)
        }
        .listStyle(.plain)
    }
    
    // 5. Row Item & Swipe Actions
    func bookRow(for book: Book) -> some View {
        NavigationLink(destination: BookEditorView(book: book)) {
            LibraryBookRow(book: book)
        }
        .swipeActions(edge: .leading) {
            if book.status == .shelf {
                Button("Start Reading") {
                    startReading(book)
                }
                .tint(.blue)
            }
        }
    }
    
    // 6. Empty State (Dipecah biar compiler gak pusing)
    var emptyStateView: some View {
        // Tentukan teks dan icon di luar ViewBuilder biar clean
        let isShelf = selectedFilter == 0
        let title = isShelf ? "No Books in Shelf" : "No Finished Books"
        let icon = isShelf ? "books.vertical" : "checkmark.seal"
        let desc = isShelf ? "Add books to your queue." : "Finish a book to see it here."
        
        return ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(desc)
        )
    }
    
    // MARK: - Actions
    
    func startReading(_ book: Book) {
        withAnimation {
            book.status = .reading
            book.lastInteraction = Date()
        }
    }
    
    func deleteBooks(at offsets: IndexSet) {
        for index in offsets {
            let book = filteredBooks[index]
            context.delete(book)
        }
    }
}
