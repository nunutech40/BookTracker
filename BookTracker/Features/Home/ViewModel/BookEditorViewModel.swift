//
//  BookEditorViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

/*
 VALIDATION STRATEGY OVERVIEW

 This ViewModel employs a user-friendly validation approach designed to provide feedback at the right moment,
 avoiding premature or overly aggressive error messages. The core theory is based on "Dirty State Tracking."

 The key principles are:
 1.  **Don't show errors too early**: A user should not see a "Title cannot be empty" error in a field they haven't even had a chance to type in yet.
 2.  **Provide immediate feedback upon interaction**: Once a user interacts with a field (i.e., it becomes "dirty"), they should get feedback if the input is invalid.
 3.  **Guide the user on save**: If the user attempts to save an incomplete or invalid form, all errors must be displayed clearly to guide them toward correction.

 To achieve this, the validation system is composed of four main parts:

 A. FORM STATE:
    - Simple `@State` properties (e.g., `title`, `author`, `totalPages`) that hold the raw user input.

 B. INTERACTION STATE (DIRTY FLAGS):
    - A set of boolean flags (e.g., `hasInteractedWithTitle`, `hasAttemptedSave`).
    - The `hasInteracted` flags are set to `true` in the `didSet` observer of their corresponding form state property. This marks a field as "dirty" once the user types in it.
    - The `hasAttemptedSave` flag is set to `true` only when the user explicitly taps the "Save" button.

 C. VALIDATION LOGIC (COMPUTED PROPERTIES):
    - A group of computed properties (e.g., `titleValidation`, `authorValidation`) that contain the pure, stateless validation rules.
    - They take the current form state and return a `ValidationState` enum (`.valid` or `.invalid(message)`).
    - These properties are "strict" and don't care about user interaction—they only evaluate the current data. The `isFormValid` property aggregates these to enable/disable the Save button.

 D. UI ERROR MESSAGE HELPER (`errorMessage(for:)` function):
    - This is the bridge between the validation logic and the UI (the View).
    - It decides whether an error message should actually be displayed.
    - An error is shown ONLY IF: `(the field is dirty OR a save has been attempted) AND the field's validation state is invalid`.
    - This logic ensures errors appear contextually, creating a smooth and intuitive user experience.
 */

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
    
    // MARK: - Interaction State (Dirty Flags)
    /// These flags track user interaction with form fields.
    /// They are crucial for determining when to display validation error messages.
    /// Errors are only shown if the user has either interacted with the field
    /// (e.g., typed something) or has attempted to save the form.
    private var hasInteractedWithTitle = false
    private var hasInteractedWithAuthor = false
    private var hasInteractedWithPages = false
    /// This flag is set to `true` when the user taps the "Save" button.
    /// It forces all validation error messages to appear simultaneously,
    /// even for fields the user hasn't explicitly interacted with yet.
    private var hasAttemptedSave = false
    
    // MARK: - Form State
    
    var title: String = "" {
        /// When the title changes, mark that the user has interacted with this field.
        didSet { hasInteractedWithTitle = true }
    }
    
    var author: String = "" {
        /// When the author changes, mark that the user has interacted with this field.
        didSet { hasInteractedWithAuthor = true }
    }
    
    /// This computed property filters non-numeric characters from the input
    /// to ensure only valid page numbers are entered.
    private var _totalPages: String = ""
    var totalPages: String {
        get { _totalPages }
        set {
            // Regex logic: Only allow characters '0' through '9'.
            let filtered = newValue.filter { "0123456789".contains($0) }
            if _totalPages != filtered {
                _totalPages = filtered
            }
            /// When totalPages changes, mark that the user has interacted with this field.
            hasInteractedWithPages = true
        }
    }
    
    var coverImageData: Data?
    var status: BookStatus = .shelf
    var isReadingNow: Bool = false
    
    // MARK: - Validation Logic (Strict)
    /// These computed properties encapsulate the validation rules for each form field.
    /// They return a `ValidationState` indicating whether the input is valid or invalid,
    /// along with a specific error message if invalid.
    /// The `isFormValid` property aggregates these states to determine overall form validity.
    
    var titleValidation: ValidationState {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        // Rule 1: Title cannot be empty or just whitespace.
        if trimmedTitle.isEmpty {
            return .invalid(message: "Title cannot be empty.")
        }
        // Rule 2: Title must be at least 3 characters long.
        if trimmedTitle.count < 3 {
            return .invalid(message: "Title must be at least 3 characters long.")
        }
        // Rule 3: Title cannot exceed 100 characters.
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
            self.isReadingNow = book.status == .reading
            
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
        
        // 3. Set status
        let newStatus: BookStatus = isReadingNow ? .reading : .shelf
        
        switch mode {
        case .create:
            let newBook = Book(
                title: title,
                author: author,
                totalPages: Int(totalPages) ?? 0,
                coverImageData: coverImageData
            )
            newBook.status = newStatus
            bookService.addBook(from: newBook)
            
        case .edit(let existingBook):
            existingBook.title = title
            existingBook.author = author
            existingBook.totalPages = Int(totalPages) ?? 0
            existingBook.coverImageData = coverImageData
            existingBook.status = newStatus
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
