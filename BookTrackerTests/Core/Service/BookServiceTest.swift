//
//  BookServiceTest.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import XCTest
import SwiftData
@testable import BookTracker // Ganti dengan nama Project aslimu

/**
 # Teori Unit Testing untuk Service Layer
 
 **1. Apa yang perlu di-test? (General Theory)**
    Dalam Unit Testing, kita tidak menes "apakah UI-nya bagus", tapi kita menes "Logic-nya benar atau tidak".
    Pola standar yang dipakai adalah **Given-When-Then** (atau Arrange-Act-Assert):
    - **Given (Modal Awal):** Siapkan data dummy (misal: Buku halaman 0).
    - **When (Aksi):** Panggil fungsi yang mau dites (misal: update ke halaman 50).
    - **Then (Ekspektasi):** Cek hasilnya (misal: halaman jadi 50, dan session bertambah 1).

 **2. Apa yang harus di-cover?**
    - **Happy Path:** Skenario normal (baca 10 halaman -> tercatat 10).
    - **Edge Cases:** Skenario aneh (salah input, mundur halaman, input negatif).
    - **State Changes:** Perubahan status (dari reading -> finished).
 
 **3. Konteks Spesifik (BookTracker):**
    Berdasarkan `BookService` yang kita buat, kita WAJIB memvalidasi:
    - **Math Logic:** Apakah $Z = X - Y$ dihitung dengan benar?
    - **Negative Handling:** Apakah koreksi halaman (X < Y) tidak dianggap sebagai sesi baca baru?
    - **Auto Finish:** Apakah status berubah jadi `.finished` saat halaman mentok?
    - **Heatmap Aggregation:** Apakah logic penjumlahan halaman per hari sudah benar?
 */

@MainActor
final class BookServiceTests: XCTestCase {
    
    // Variable yang akan dipakai di setiap test
    var service: BookService!
    var modelContext: ModelContext!
    var container: ModelContainer!
    
    // Setup: Dijalankan SEBELUM setiap fungsi test dimulai
    override func setUp() async throws {
        // 1. Buat Schema SwiftData
        let config = ModelConfiguration(isStoredInMemoryOnly: true) // PENTING: Pakai RAM saja, jangan simpan ke Disk
        container = try ModelContainer(for: Book.self, ReadingSession.self, configurations: config)
        modelContext = container.mainContext
        
        // 2. Inisialisasi Service dengan Context In-Memory tadi
        service = BookService(modelContext: modelContext)
    }
    
    // Teardown: Dijalankan SETELAH setiap fungsi test selesai (Cleanup)
    override func tearDown() async throws {
        service = nil
        modelContext = nil
        container = nil
    }
    
    // MARK: - Test Logic: Update Progress ($Z = X - Y$)
    
    func testUpdateProgress_PositiveIncrement_ShouldCreateSession() {
        // GIVEN: Buku baru dengan 100 halaman, posisi 0
        let book = Book(title: "Test Book", totalPages: 100)
        modelContext.insert(book)
        
        // WHEN: User membaca sampai halaman 50
        service.updateProgress(for: book, newPage: 50)
        
        // THEN:
        // 1. Halaman buku harus 50
        XCTAssertEqual(book.currentPage, 50, "Current page harus terupdate jadi 50")
        // 2. Status masih reading
        XCTAssertEqual(book.status, .reading)
        // 3. Session harus bertambah 1
        XCTAssertEqual(book.sessions.count, 1, "Harus ada 1 reading session")
        // 4. Jumlah halaman di session harus 50 (50 - 0)
        XCTAssertEqual(book.sessions.first?.pagesReadCount, 50, "Session harus mencatat 50 halaman")
    }
    
    func testUpdateProgress_CorrectionBackwards_ShouldNotCreateSession() {
        // GIVEN: Buku posisi halaman 50
        let book = Book(title: "Test Book", totalPages: 100)
        book.currentPage = 50
        modelContext.insert(book)
        
        // WHEN: User merevisi ke halaman 40 (Mundur/Koreksi)
        service.updateProgress(for: book, newPage: 40)
        
        // THEN:
        // 1. Halaman buku tetap terupdate jadi 40
        XCTAssertEqual(book.currentPage, 40)
        // 2. TAPI, tidak boleh ada session baru (karena Z < 0)
        XCTAssertTrue(book.sessions.isEmpty, "Tidak boleh ada session jika progress mundur")
    }
    
    func testUpdateProgress_FinishBook_ShouldChangeStatus() {
        // GIVEN: Buku posisi 90/100
        let book = Book(title: "Test Book", totalPages: 100)
        book.currentPage = 90
        modelContext.insert(book)
        
        // WHEN: User update ke 100
        service.updateProgress(for: book, newPage: 100)
        
        // THEN: Status harus otomatis finished
        XCTAssertEqual(book.status, .finished, "Status harus berubah jadi finished saat halaman mentok")
        XCTAssertEqual(book.currentPage, 100)
    }
    
    // MARK: - Test Logic: Quick Finish (One-Tap)
    
    func testFinishBook_Instant_ShouldCalculateRemainingPages() {
        // GIVEN: Buku posisi 50/100
        let book = Book(title: "Test Book", totalPages: 100)
        book.currentPage = 50
        modelContext.insert(book)
        
        // WHEN: User tekan tombol 'Finish'
        service.finishBook(book)
        
        // THEN:
        // 1. Halaman jadi 100
        XCTAssertEqual(book.currentPage, 100)
        // 2. Status finished
        XCTAssertEqual(book.status, .finished)
        // 3. Ada session baru sebesar sisa halaman (100 - 50 = 50)
        XCTAssertEqual(book.sessions.count, 1)
        XCTAssertEqual(book.sessions.first?.pagesReadCount, 50, "Harus mencatat sisa 50 halaman")
    }
    
    // MARK: - Test Logic: Heatmap Calculation
    
    func testFetchHeatmap_Aggregation_ShouldSumPagesPerDay() {
        // GIVEN: 2 Sesi baca di HARI YANG SAMA
        let today = Date()
        let session1 = ReadingSession(date: today, pagesReadCount: 20)
        let session2 = ReadingSession(date: today, pagesReadCount: 30)
        modelContext.insert(session1)
        modelContext.insert(session2)
        
        // WHEN: Fetch heatmap data
        let result = service.fetchReadingHeatmap()
        
        // THEN: Harus ada 1 entry tanggal dengan total 50 halaman
        let startOfDay = Calendar.current.startOfDay(for: today)
        XCTAssertEqual(result[startOfDay], 50, "Total halaman hari ini harusnya 20 + 30 = 50")
    }
    
    // MARK: - Test Integration: Add Book
    
    func testAddBook_FromAPI_ShouldSaveToDatabase() {
        // GIVEN: Data dummy dari API (Mocking)
        let mockImageLinks = GoogleBookImageLinks(thumbnail: "http://example.com/img.jpg")
        let mockVolume = GoogleBookVolumeInfo(title: "Mock Book", authors: ["Nunu"], pageCount: 200, imageLinks: mockImageLinks)
        let mockItem = GoogleBookItem(id: "123", volumeInfo: mockVolume)
        
        // WHEN: Service add book
        service.addBook(from: mockItem, coverData: Data()) // Data dummy kosong
        
        // THEN: Cek apakah masuk ke Database
        let descriptor = FetchDescriptor<Book>()
        let books = try? modelContext.fetch(descriptor)
        
        XCTAssertEqual(books?.count, 1)
        XCTAssertEqual(books?.first?.title, "Mock Book")
        XCTAssertEqual(books?.first?.totalPages, 200)
    }
}
