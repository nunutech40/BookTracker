//
//  AddBookView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

struct AddBookView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AddBookViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Content
                if viewModel.isLoading {
                    ProgressView("Working...")
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.searchResults.isEmpty && !viewModel.query.isEmpty {
                    ContentUnavailableView.search(text: viewModel.query)
                } else if viewModel.searchResults.isEmpty {
                    ContentUnavailableView("Find Your Book", systemImage: "magnifyingglass", description: Text("Search by title, author, or ISBN"))
                } else {
                    resultsList
                }
            }
            .navigationTitle("Add New Book")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query, prompt: "Harry Potter, Atomic Habits...")
            .onSubmit(of: .search) {
                Task { await viewModel.searchBooks() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.setup(context: context)
        }
    }
}

// MARK: - Subviews
private extension AddBookView {
    
    var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { item in
                    SearchResultRow(item: item) {
                        // Action saat tombol ADD ditekan
                        Task {
                            await viewModel.addBookToLibrary(item: item)
                            dismiss() // Tutup sheet setelah save
                        }
                    }
                }
            }
            .padding()
        }
    }
}
