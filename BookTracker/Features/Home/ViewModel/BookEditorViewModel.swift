//
//  BookEditorViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

@Observable
final class BookEditorViewModel {
    
    // MARK: - Mode Definition
    enum EditorMode {
        case create
        case edit(Book)
    }
    
    // MARK: - Dependencies
    private var googleBookService: GoogleBooksService
    private var bookService: BookService
    
    let mode: EditorMode
    
    // MARK: - Form State (Gak perlu @Published kalau pake @Observable)
    var title: String = ""
    var author: String = ""
    var totalPages: String = ""
    var coverImageData: Data?
    var status: BookStatus = .shelf
    
    // MARK: - Photo Picker State & Logic
    // ✅ PERBAIKAN: Hanya dideklarasikan 1 kali + Logic Trigger
    var photoSelection: PhotosPickerItem? {
        didSet {
            if let item = photoSelection {
                Task { await loadPhoto(from: item) }
            }
        }
    }
    
    // MARK: - Search State
    var showSearchSheet: Bool = false
    var query: String = ""
    var searchResults: [GoogleBookItem] = []
    var isSearching: Bool = false
    var searchError: String?
    
    // MARK: - Init
    init(googleBookService: GoogleBooksService, bookService: BookService, book: Book? = nil) {
        self.googleBookService = googleBookService
        self.bookService = bookService
        
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
    
    // MARK: - Photo Logic (Internal)
    @MainActor
    func loadPhoto(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                // Resize & Compress Image
                self.process(data: data)
            }
        } catch {
            print("❌ Gagal load foto: \(error)")
        }
    }
    
    /// Processes image data (from PhotosPicker or URL) by resizing and compressing it.
    func process(data: Data?) {
        guard let data = data, let image = UIImage(data: data) else { return }
        self.coverImageData = _process(image: image)
    }
    
    /// Processes a UIImage (from Camera) by resizing and compressing it.
    func process(image: UIImage) {
        self.coverImageData = _process(image: image)
    }

    /// The core image processing function. Resizes and compresses the image.
    private func _process(image: UIImage) -> Data? {
        let targetSize = CGSize(width: 500, height: 500)
        guard let scaledImage = image.preparingThumbnail(of: targetSize) else { return nil }
        
        // Compress to JPEG with high quality
        return scaledImage.jpegData(compressionQuality: 0.8)
    }

    // MARK: - Logic Save
    @MainActor
    func save() -> Bool {
        print("🖨️ [ViewModel] Saving...")
        
        // Validasi
        guard !title.isEmpty, let pagesInt = Int(totalPages), pagesInt > 0 else {
            print("   ❌ Validasi Gagal!")
            return false
        }
        
        switch mode {
        case .create:
            let newBook = Book(
                title: title,
                author: author,
                totalPages: pagesInt,
                coverImageData: coverImageData
            )
            newBook.status = status
            bookService.addBook(from: newBook)
            
        case .edit(let existingBook):
            existingBook.title = title
            existingBook.author = author
            existingBook.totalPages = pagesInt
            existingBook.coverImageData = coverImageData
            existingBook.status = status
        }
        
        return true
    }
    
    @MainActor
    func deleteBook() {
        if case .edit(let book) = mode {
            bookService.deleteBook(book)
        }
    }
    
    // MARK: - Search Logic
    func searchBooks() async {
        guard !query.isEmpty else { return }
        isSearching = true
        searchError = nil
        do {
            searchResults = try await googleBookService.searchBooks(query: query)
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
            let data = await googleBookService.downloadCoverImage(from: url)
            // Also process image from URL
            self.process(data: data)
        }
        
        showSearchSheet = false
    }
}
