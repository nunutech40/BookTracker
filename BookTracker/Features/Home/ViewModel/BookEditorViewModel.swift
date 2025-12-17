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
    
    // ... (Enum & Dependencies Tetap Sama) ...
    enum EditorMode {
        case create
        case edit(Book)
    }
    
    private var googleBookService: GoogleBooksService
    private var bookService: BookService
    
    let mode: EditorMode
    
    // MARK: - Interaction State (Dirty Flags) ✅ BARU
    // Ini gunanya buat nandain: "User udah nyentuh field ini belum?"
    private var hasInteractedWithTitle = false
    private var hasInteractedWithAuthor = false
    private var hasInteractedWithPages = false
    private var hasAttemptedSave = false // Buat maksa munculin semua error pas klik Save
    
    // MARK: - Form State
    
    var title: String = "" {
        didSet { hasInteractedWithTitle = true } // ✅ Auto update flag
    }
    
    var author: String = "" {
        didSet { hasInteractedWithAuthor = true } // ✅ Auto update flag
    }
    
    // Logic Filter Angka
    private var _totalPages: String = ""
    var totalPages: String {
        get { _totalPages }
        set {
            let filtered = newValue.filter { "0123456789".contains($0) }
            if _totalPages != filtered {
                _totalPages = filtered
            }
            hasInteractedWithPages = true // ✅ Auto update flag
        }
    }
    
    var coverImageData: Data?
    var status: BookStatus = .shelf
    
    // MARK: - Validation Logic (Strict)
    // Ini Logic Murni (Benar/Salah), dipake buat disable tombol Save
    
    var titleValidation: ValidationState {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            return .invalid(message: "Title cannot be empty.")
        }
        if trimmedTitle.count < 3 {
            return .invalid(message: "Title must be at least 3 characters long.")
        }
        if trimmedTitle.count > 100 {
            return .invalid(message: "Title cannot be longer than 100 characters.")
        }
        return .valid
    }
    
    var authorValidation: ValidationState {
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedAuthor.isEmpty {
            return .invalid(message: "Author cannot be empty.")
        }
        if trimmedAuthor.count < 3 {
            return .invalid(message: "Author must be at least 3 characters long.")
        }
        if trimmedAuthor.count > 50 {
            return .invalid(message: "Author cannot be longer than 50 characters.")
        }
        return .valid
    }
    
    var totalPagesValidation: ValidationState {
        if totalPages.isEmpty {
            return .invalid(message: "Total pages cannot be empty.")
        }
        guard let pagesInt = Int(totalPages) else {
            return .invalid(message: "Enter a valid number.")
        }
        if pagesInt < 1 {
            return .invalid(message: "Total pages must be at least 1.")
        }
        if pagesInt > 9999 {
            return .invalid(message: "Total pages cannot exceed 9999.")
        }
        return .valid
    }
    
    var isFormValid: Bool {
        return titleValidation == .valid &&
        authorValidation == .valid &&
        totalPagesValidation == .valid
    }
    
    // MARK: - UI Helper: Error Message Display ✅ BARU
    // Fungsi ini yang dipanggil View. Dia nentuin "Boleh tampilin error gak?"
    // Syarat tampil: (User udah ngetik ATAU User udah tekan Save) DAN (Datanya Invalid)
    
    func errorMessage(for field: FieldType) -> String? {
        let shouldShow: Bool
        let state: ValidationState
        
        switch field {
        case .title:
            shouldShow = hasInteractedWithTitle || hasAttemptedSave
            state = titleValidation
        case .author:
            shouldShow = hasInteractedWithAuthor || hasAttemptedSave
            state = authorValidation
        case .totalPages:
            shouldShow = hasInteractedWithPages || hasAttemptedSave
            state = totalPagesValidation
        }
        
        if shouldShow, let message = state.message {
            return message
        }
        return nil
    }
    
    enum FieldType { case title, author, totalPages }
    
    // ... (Photo Picker State & Search State Tetap Sama) ...
    var photoSelection: PhotosPickerItem? {
        didSet {
            if let item = photoSelection {
                Task { await loadPhoto(from: item) }
            }
        }
    }
    
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
            self._totalPages = String(book.totalPages)
            self.coverImageData = book.coverImageData
            self.status = book.status
            
            // Kalau Edit Mode, anggap user sudah interaksi (biar validasi jalan normal)
            self.hasInteractedWithTitle = true
            self.hasInteractedWithAuthor = true
            self.hasInteractedWithPages = true
        } else {
            self.mode = .create
            self.status = .shelf
        }
    }
    
    // ... (Photo Logic Internal Tetap Sama) ...
    @MainActor
    func loadPhoto(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                process(data: data)
            }
        } catch {
            print("❌ Gagal load foto: \(error)")
        }
    }
    
    func process(data: Data?) {
        guard let data = data, let image = UIImage(data: data) else { return }
        self.coverImageData = _process(image: image)
    }
    
    func process(image: UIImage) {
        self.coverImageData = _process(image: image)
    }
    
    private func _process(image: UIImage) -> Data? {
        let targetSize = CGSize(width: 500, height: 500)
        guard let scaledImage = image.preparingThumbnail(of: targetSize) else { return nil }
        return scaledImage.jpegData(compressionQuality: 0.8)
    }
    
    // MARK: - Core Actions
    @MainActor
    func save() -> Bool {
        // 1. Tandai user sudah mencoba save (munculkan semua merah-merah)
        hasAttemptedSave = true
        
        // 2. Cek validasi
        guard isFormValid else { return false }
        
        switch mode {
        case .create:
            let newBook = Book(
                title: title,
                author: author,
                totalPages: Int(totalPages) ?? 0,
                coverImageData: coverImageData
            )
            newBook.status = status
            bookService.addBook(from: newBook)
            
        case .edit(let existingBook):
            existingBook.title = title
            existingBook.author = author
            existingBook.totalPages = Int(totalPages) ?? 0
            existingBook.coverImageData = coverImageData
            existingBook.status = status
        }
        
        return true
    }
    
    // ... (Delete & Search & Autofill Tetap Sama) ...
    @MainActor
    func deleteBook() {
        if case .edit(let book) = mode {
            bookService.deleteBook(book)
        }
    }
    
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
        
        // Autofill dianggap interaksi user
        self.hasInteractedWithTitle = true
        self.hasInteractedWithAuthor = true
        self.hasInteractedWithPages = true
        
        if let url = item.volumeInfo.imageLinks?.thumbnail {
            let data = await googleBookService.downloadCoverImage(from: url)
            self.process(data: data)
        }
        
        showSearchSheet = false
    }
}
