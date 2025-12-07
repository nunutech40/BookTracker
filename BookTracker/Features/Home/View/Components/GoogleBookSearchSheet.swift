//
//  GoogleBookSearchSheet.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct GoogleBooksSearchSheet: View {
    @Bindable var viewModel: BookEditorViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isSearching {
                    ProgressView("Searching...")
                } else if let error = viewModel.searchError {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else if viewModel.searchResults.isEmpty {
                    ContentUnavailableView("Search Books", systemImage: "magnifyingglass", description: Text("Enter title or author"))
                } else {
                    List(viewModel.searchResults) { item in
                        SearchResultRow(item: item) {
                            // ACTION: AUTOFILL & CLOSE
                            Task {
                                await viewModel.autofillForm(with: item)
                                // Sheet tertutup otomatis karena viewModel.showSearchSheet di-set false di logic autofill
                            }
                        }
                    }
                }
            }
            .navigationTitle("Google Books")
            .searchable(text: $viewModel.query)
            .onSubmit(of: .search) {
                Task { await viewModel.searchBooks() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { viewModel.showSearchSheet = false }
                }
            }
        }
    }
}
