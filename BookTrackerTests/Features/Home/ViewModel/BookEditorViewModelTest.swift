//
//  BookEditorViewModelTest.swift
//  BookTrackerTests
//
//  Created by Nunu Nugraha on 18/12/25.
//

import XCTest
@testable import BookTracker

/**
 `BookEditorViewModelTest`
 
 Test suite for `BookEditorViewModel`.
 
 **Tujuan Utama Pengujian:**
 1.  **Memverifikasi Inisialisasi:** Memastikan `ViewModel` diinisialisasi dengan benar dalam mode pembuatan dan pengeditan.
 2.  **Memvalidasi Input Pengguna:** Menguji aturan validasi untuk judul, penulis, dan jumlah halaman.
 3.  **Memastikan Aksi Core:** Memverifikasi bahwa metode `save()` dan `deleteBook()` berinteraksi dengan `BookService` dengan benar.
 4.  **Menguji Integrasi Google Books API:** Memastikan bahwa pencarian dan pengisian otomatis berfungsi sesuai harapan melalui `GoogleBooksService`.
 
 **Struktur Pengujian:**
 -   **Given:** Menyiapkan kondisi, termasuk inisialisasi `ViewModel` dengan `MockBookService` dan `MockGoogleBookService`.
 -   **When:** Menjalankan metode yang akan diuji (misalnya, `save()`, `deleteBook()`, `searchBooks()`).
 -   **Then:** Memverifikasi bahwa `state` `ViewModel` telah diperbarui dengan benar dan `Service` yang relevan telah dipanggil dengan argumen yang benar.
 */
final class BookEditorViewModelTest: XCTestCase {
    
    var sut: BookEditorViewModel!
    var mockBookService: MockBookService!
    var mockGoogleBookService: MockGoogleBooksService!
    
    override func setUp() {
        super.setUp()
        mockBookService = MockBookService()
        mockGoogleBookService = MockGoogleBooksService()
    }
    
    override func tearDown() {
        sut = nil
        mockBookService = nil
        mockGoogleBookService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    /// **Apa yang diuji:** Memastikan `ViewModel` diinisialisasi dengan benar dalam mode `.create`.
    /// **Mengapa:** Penting untuk memastikan semua properti berada dalam keadaan awal yang diharapkan untuk pembuatan buku baru.
    func test_init_createMode() {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        
        XCTAssertEqual(sut.title, "")
        XCTAssertEqual(sut.author, "")
        XCTAssertEqual(sut.totalPages, "")
        XCTAssertNil(sut.coverImageData)
        XCTAssertFalse(sut.isReadingNow)
        
        if case .create = sut.mode {
            // Success
        } else {
            XCTFail("Mode should be .create")
        }
    }
    
    /// **Apa yang diuji:** Memastikan `ViewModel` diinisialisasi dengan benar dalam mode `.edit` dengan data buku yang ada.
    /// **Mengapa:** Penting untuk memastikan bahwa `ViewModel` memuat data buku yang benar untuk diedit.
    func test_init_editMode() {
        let book = Book(title: "Test Title", author: "Test Author", totalPages: 100)
        book.status = .reading
        
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService, book: book)
        
        XCTAssertEqual(sut.title, "Test Title")
        XCTAssertEqual(sut.author, "Test Author")
        XCTAssertEqual(sut.totalPages, "100")
        XCTAssertTrue(sut.isReadingNow)
        
        if case .edit(let editableBook) = sut.mode {
            XCTAssertEqual(editableBook.id, book.id)
        } else {
            XCTFail("Mode should be .edit")
        }
    }
    
    // MARK: - Validation Tests
    
    /// **Apa yang diuji:** Memastikan pesan validasi muncul dengan benar saat bidang kosong dan percobaan penyimpanan dilakukan.
    /// **Mengapa:** Validasi harus memandu pengguna untuk mengisi data yang diperlukan sebelum menyimpan.
    @MainActor func test_validation_emptyFields() {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        
        // Initial state should be invalid but no messages
        XCTAssertFalse(sut.isFormValid)
        XCTAssertNil(sut.errorMessage(for: .title))
        
        // After save attempt, messages should appear
        _ = sut.save()
        XCTAssertNotNil(sut.errorMessage(for: .title))
        XCTAssertNotNil(sut.errorMessage(for: .author))
        XCTAssertNotNil(sut.errorMessage(for: .totalPages))
    }
    
    /// **Apa yang diuji:** Memastikan bahwa data yang valid tidak menghasilkan pesan kesalahan.
    /// **Mengapa:** Memverifikasi bahwa aturan validasi tidak secara keliru menandai input yang benar sebagai tidak valid.
    func test_validation_validData() {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        sut.title = "Valid Title"
        sut.author = "Valid Author"
        sut.totalPages = "123"
        
        XCTAssertTrue(sut.isFormValid)
        XCTAssertNil(sut.errorMessage(for: .title))
        XCTAssertNil(sut.errorMessage(for: .author))
        XCTAssertNil(sut.errorMessage(for: .totalPages))
    }
    
    // MARK: - Core Action Tests
    
    /// **Apa yang diuji:** Memverifikasi bahwa metode `save()` dalam mode `.create` memanggil `addBook` pada `BookService`.
    /// **Mengapa:** Memastikan logika penyimpanan buku baru mendelegasikan ke layanan dengan benar.
    @MainActor func test_save_createMode() {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        sut.title = "New Book"
        sut.author = "New Author"
        sut.totalPages = "200"
        
        let success = sut.save()
        
        XCTAssertTrue(success)
        XCTAssertTrue(mockBookService.addBookCalled)
    }
    
    /// **Apa yang diuji:** Memverifikasi bahwa metode `save()` dalam mode `.edit` memperbarui properti buku yang ada.
    /// **Mengapa:** Memastikan bahwa pengeditan buku yang ada tercermin dalam objek buku dan tidak membuat buku baru.
    @MainActor func test_save_editMode() {
        let book = Book(title: "Old Title", author: "Old Author", totalPages: 100)
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService, book: book)
        
        sut.title = "Updated Title"
        let success = sut.save()
        
        XCTAssertTrue(success)
        XCTAssertTrue(mockBookService.updateBookCalled)
        XCTAssertEqual(mockBookService.updatedBook?.title, "Updated Title")
    }
    
    /// **Apa yang diuji:** Memverifikasi bahwa metode `deleteBook()` memanggil `deleteBook` pada `BookService`.
    /// **Mengapa:** Memastikan logika penghapusan buku mendelegasikan ke layanan dengan benar.
    @MainActor func test_deleteBook() {
        let book = Book(title: "To Be Deleted", author: "Author", totalPages: 50)
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService, book: book)
        
        sut.deleteBook()
        
        XCTAssertTrue(mockBookService.deleteBookCalled)
    }
    
    // MARK: - Google Books API Tests
    
    /// **Apa yang diuji:** Memastikan bahwa pencarian buku melalui `GoogleBooksService` berhasil dan memperbarui hasil pencarian.
    /// **Mengapa:** Menguji integrasi yang benar dengan layanan Google Books untuk mengambil data buku.
    func test_searchBooks_success() async {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        mockGoogleBookService.searchResult = .success([
            GoogleBookItem(id: "1", volumeInfo: GoogleBookVolumeInfo(title: "Searched Book", authors: ["Author"], pageCount: 300, imageLinks: nil))
        ])
        
        sut.query = "Swift"
        await sut.searchBooks()
        
        XCTAssertFalse(sut.searchResults.isEmpty)
        XCTAssertEqual(sut.searchResults.first?.volumeInfo.title, "Searched Book")
        XCTAssertNil(sut.searchError)
    }
    
    /// **Apa yang diuji:** Memastikan bahwa formulir terisi otomatis dengan benar menggunakan data dari `GoogleBookItem`.
    /// **Mengapa:** Menguji bahwa data yang diambil dari API Google Books dapat digunakan untuk mengisi bidang formulir.
    func test_autofillForm() async {
        sut = BookEditorViewModel(googleBookService: mockGoogleBookService, bookService: mockBookService)
        let item = GoogleBookItem(id: "1", volumeInfo: GoogleBookVolumeInfo(title: "Autofill Book", authors: ["Autofill Author"], pageCount: 400, imageLinks: nil))
        
        await sut.autofillForm(with: item)
        
        XCTAssertEqual(sut.title, "Autofill Book")
        XCTAssertEqual(sut.author, "Autofill Author")
        XCTAssertEqual(sut.totalPages, "400")
        XCTAssertFalse(sut.showSearchSheet)
    }
}

class MockGoogleBooksService: GoogleBooksServiceProtocol {
    var searchResult: Result<[GoogleBookItem], Error> = .success([])
    var downloadedCover: Data?
    
    func searchBooks(query: String) async throws -> [GoogleBookItem] {
        switch searchResult {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
    
    func downloadCoverImage(from urlString: String?) async -> Data? {
        return downloadedCover
    }
}
