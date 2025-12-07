//
//  BookEditorViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI

@Observable
final class BookEditorViewModel {
    
    // MARK: - Mode Definition
    enum EditorMode {
        case create
        case edit(Book)
    }
    
    let mode: EditorMode
    
    // MARK: - Form State
    var title: String = ""
    var author: String = ""
    var totalPages: String = ""
    var coverImageData: Data?
    var status: BookStatus = .shelf
    
    // MARK: - Photo Picker State (INI YG BIKIN ERROR KALO GAK ADA)
    var photoSelection: PhotosPickerItem? = nil
    
    // MARK: - Search State
    var showSearchSheet: Bool = false
    var query: String = ""
    var searchResults: [GoogleBookItem] = []
    var isSearching: Bool = false
    var searchError: String?
    
    // Dependencies
    private var googleService = GoogleBooksService()
    
    // MARK: - Init
    init(book: Book? = nil) {
        if let book = book {
            self.mode = .edit(book)
            self.title = book.title
            self.author = book.author
            self.totalPages = String(book.totalPages)
            self.coverImageData = book.coverImageData
            self.status = book.status
        } else {
            self.mode = .create
            self.status = .shelf
        }
    }
    
    // MARK: - Photo Logic
    func loadPhoto() async {
        guard let item = photoSelection else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.coverImageData = data
            }
        } catch {
            print("Gagal load foto: \(error)")
        }
    }
    
    // MARK: - Logic Save (DEBUGGED)
    func save(context: ModelContext) -> Bool {
        print("🖨️ [ViewModel] Tombol Save Ditekan!")
        print("   Input -> Title: '\(title)', Pages: \(totalPages), Status Pilihan: \(status.rawValue)")
        
        // Validasi
        guard !title.isEmpty, let pagesInt = Int(totalPages), pagesInt > 0 else {
            print("   ❌ Validasi Gagal! Judul/Halaman kosong.")
            return false
        }
        
        switch mode {
        case .create:
            print("   Mode: CREATE NEW")
            let newBook = Book(
                title: title,
                author: author,
                totalPages: pagesInt,
                coverImageData: coverImageData
            )
            newBook.status = status // Pastikan status kebawa
            print("   Inserting Book with Status: \(newBook.status.rawValue)...")
            context.insert(newBook)
            
        case .edit(let existingBook):
            print("   Mode: EDIT EXISTING")
            existingBook.title = title
            existingBook.author = author
            existingBook.totalPages = pagesInt
            existingBook.coverImageData = coverImageData
            existingBook.status = status
            print("   Updating Book Status to: \(existingBook.status.rawValue)")
        }
        
        do {
            try context.save()
            print("   ✅ SUCCESS! Data tersimpan di SwiftData.")
            return true
        } catch {
            print("   ❌ CRITICAL ERROR: Gagal save ke Context! \(error)")
            return false
        }
    }
    
    func deleteBook(context: ModelContext) {
        if case .edit(let book) = mode {
            context.delete(book)
            try? context.save()
        }
    }
    
    // MARK: - Search Logic
    func searchBooks() async {
        guard !query.isEmpty else { return }
        isSearching = true
        searchError = nil
        do {
            searchResults = try await googleService.searchBooks(query: query)
            if searchResults.isEmpty { searchError = "Buku tidak ditemukan." }
        } catch {
            searchError = "Gagal koneksi internet."
        }
        isSearching = false
    }
    
    func autofillForm(with item: GoogleBookItem) async {
        self.title = item.volumeInfo.title
        self.author = item.volumeInfo.authors?.joined(separator: ", ") ?? ""
        self.totalPages = String(item.volumeInfo.pageCount ?? 0)
        if let url = item.volumeInfo.imageLinks?.thumbnail {
            self.coverImageData = await googleService.downloadCoverImage(from: url)
        }
        showSearchSheet = false
    }
}
