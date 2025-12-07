//
//  AddBookViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

@Observable
final class AddBookViewModel {
    
    // State UI
    var query: String = ""
    var searchResults: [GoogleBookItem] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // Dependencies
    private var googleService = GoogleBooksService() // Service API
    private var bookService: BookService?          // Service Database
    
    // Setup Context Untuk Save ke data ke SwiftData
    func setup(context: ModelContext) {
        self.bookService = BookService(modelContext: context)
    }
    
    // MARK: - Actions
    
    func searchBooks() async {
        guard !query.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Panggil Google Books API
            let results = try await googleService.searchBooks(query: query)
            self.searchResults = results
        } catch {
            self.errorMessage = "Gagal mencari buku. Cek koneksi internet."
        }
        
        isLoading = false
    }
    
    func addBookToLibrary(item: GoogleBookItem) async {
        guard let bookService = bookService else { return }
        
        isLoading = true // Show loading pas download gambar
        
        // 1. Download Cover Image (URL -> Data)
        let urlString = item.volumeInfo.imageLinks?.thumbnail
        let coverData = await googleService.downloadCoverImage(from: urlString)
        
        // 2. Save ke SwiftData via BookService
        await bookService.addBook(from: item, coverData: coverData)
        
        isLoading = false
        // Note: View akan otomatis dismiss karena kita handle di UI nanti
    }
}
