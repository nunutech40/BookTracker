//
//  BookService.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import SwiftData

/**
 # BookService (Business Logic Layer)
 
 **Tujuan (Why):**
 Class ini dibuat untuk memisahkan **Logic Bisnis** dari UI/ViewModel. Tujuannya agar ViewModel tetap bersih (hanya mengurus State) dan logic manipulasi data terpusat di satu tempat yang aman dan reusable.
 
 **Teknologi Stack:**
 - **SwiftData (`ModelContext`):** Digunakan untuk CRUD (Create, Read, Update, Delete) ke database lokal.
 - **Swift Concurrency (`@MainActor`):** Memastikan operasi data yang berdampak ke UI berjalan di thread utama.
 
 **Algoritma Utama:**
 1. **Progress Tracking ($Z = X - Y$):** Menghitung selisih halaman baru dengan halaman lama untuk menentukan apakah perlu mencatat `ReadingSession`.
 2. **Data Aggregation:** Mengelompokkan history bacaan berdasarkan tanggal untuk kebutuhan visualisasi Heatmap (mirip kontribusi GitHub).
 */
@preconcurrency final class BookService: BookServiceProtocol {
    
    /// Context database (penghubung ke storage fisik)
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Core Logic: Update Progress
    
    /**
     Mengupdate progress bacaan user dan mencatat history sesi baca secara otomatis.
     
     **Algoritma ($Z = X - Y$):**
     1. Ambil halaman baru (**X**) dan halaman lama (**Y**).
     2. Hitung delta **Z = X - Y**.
     3. **Validasi:** Jika **Z < 0** (user mundur halaman), anggap progress 0 (tidak dicatat di history), tapi tetap update posisi halaman di buku.
     4. **Recording:** Jika **Z > 0**, buat object `ReadingSession` baru.
     5. **Auto-Status:** Jika halaman >= total halaman, ubah status buku jadi `.finished`.
     
     - Parameters:
     - book: Object `Book` yang sedang aktif (Reference Type, langsung terupdate).
     - newPage: Input angka halaman terbaru dari user.
     */
    // MARK: - Core Logic: Update Progress
    func updateProgress(for book: Book, newPage: Int) {
        print("🖨️ [BookService] Updating Progress for: \(book.title)")
        print("   Current: \(book.currentPage), New: \(newPage), Status Awal: \(book.status.rawValue)")
        
        let x = newPage
        let y = book.currentPage
        
        var z = x - y
        
        if z < 0 {
            print("   ⚠️ User input halaman mundur (Delta Negatif). Z di-set 0.")
            z = 0
        }
        
        // Update State
        book.currentPage = x
        book.lastInteraction = Date()
        
        // Auto-Status Logic
        if book.currentPage >= book.totalPages {
            print("   🎉 Book Finished! (Current \(book.currentPage) >= Total \(book.totalPages))")
            book.currentPage = book.totalPages
            book.status = .finished
        } else {
            // Re-reading logic
            if book.status == .finished {
                print("   📖 Status changed back to READING (User re-reading)")
            }
            book.status = .reading
        }
        
        // Create History
        if z > 0 {
            print("   📝 Mencatat ReadingSession: +\(z) pages")
            let session = ReadingSession(date: Date(), pagesReadCount: z)
            session.book = book
            modelContext.insert(session)
        } else {
            print("   ℹ️ Tidak ada progress halaman (Z=0), skip sesi.")
        }
        
        // Persist
        do {
            try modelContext.save()
            print("   ✅ Save Success! Status Akhir: \(book.status.rawValue)")
        } catch {
            print("   ❌ ERROR Saving Context: \(error)")
        }
    }
    
    // MARK: - Feature: GitHub-Style Heatmap
    
    /**
     Mengambil data sesi baca untuk visualisasi grafik kontribusi (Heatmap).
     
     **Logic Aggregation:**
     1. Fetch semua `ReadingSession` dari database.
     2. **Grouping:** Kelompokkan data berdasarkan tanggal (Start of Day).
     3. **Reduce:** Jumlahkan `pagesReadCount` untuk setiap tanggal.
     
     - Returns: Dictionary `[Date: Int]` di mana Key = Tanggal, Value = Total halaman dibaca hari itu.
     */
    // MARK: - Heatmap
    func fetchReadingHeatmap() -> [Date: Int] {
        print("🖨️ [BookService] Fetching Heatmap Data...")
        let descriptor = FetchDescriptor<ReadingSession>()
        
        guard let sessions = try? modelContext.fetch(descriptor) else {
            print("   ❌ Fetch Failed")
            return [:]
        }
        
        print("   Found \(sessions.count) total reading sessions.")
        
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }
        
        return grouped.mapValues { sessions in
            sessions.reduce(0) { $0 + $1.pagesReadCount }
        }
    }

    func fetchReadingHeatmap(forLastMonths months: Int) -> [Date: Int] {
        print("🖨️ [BookService] Fetching Heatmap Data for last \(months) months...")
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .month, value: -months, to: today) else {
            return [:]
        }

        let predicate = #Predicate<ReadingSession> { session in
            session.date >= startDate
        }
        
        var descriptor = FetchDescriptor<ReadingSession>(predicate: predicate)
        
        guard let sessions = try? modelContext.fetch(descriptor) else {
            print("   ❌ Fetch Failed")
            return [:]
        }
        
        print("   Found \(sessions.count) reading sessions in the last \(months) months.")
        
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        return grouped.mapValues { sessions in
            sessions.reduce(0) { $0 + $1.pagesReadCount }
        }
    }
    
    // MARK: - Feature: Add Book from API
    
    /**
     Menyimpan buku baru hasil pencarian API Google Books ke database lokal.
     
     **Cara Kerja:**
     Menerima raw data dari API (`GoogleBookItem`) dan data gambar (`Data`),
     lalu mengkonversinya menjadi object `Book` yang kompatibel dengan SwiftData.
     
     - Parameters:
     - apiBook: Raw object dari Google Books API.
     - coverData: Binary data gambar (hasil download) agar bisa diakses offline.
     */
    @MainActor
    func addBook(from apiBook: GoogleBookItem, coverData: Data?) {
        print("🖨️ [BookService] Adding Book from API: \(apiBook.volumeInfo.title)")
        
        let title = apiBook.volumeInfo.title
        let totalPages = apiBook.volumeInfo.pageCount ?? 100
        let author = apiBook.volumeInfo.authors?.first ?? "Unknown"
        
        let newBook = Book(title: title, author: author, totalPages: totalPages, coverImageData: coverData)
        // Default API biasanya masuk ke Shelf
        newBook.status = .shelf
        
        modelContext.insert(newBook)
        
        do {
            try modelContext.save()
            print("   ✅ Book Saved Successfully! (Title: \(title))")
        } catch {
            print("   ❌ Failed to save book: \(error)")
        }
    }
    
    @MainActor
    func addBook(from book: Book) {
        modelContext.insert(book)
        do {
            try modelContext.save()
        } catch {
            print("   ❌ Failed to save book: \(error)")
        }
    }
    
    @MainActor
    func deleteBook(_ book: Book) {
        modelContext.delete(book)
        do {
            try modelContext.save()
        } catch {
            print("   ❌ Failed to save book: \(error)")
        }
    }
    
    // MARK: - Feature: Quick Finish
    
    /**
     Menamatkan buku secara instan tanpa input manual halaman.
     
     **Logic:**
     Fungsi ini menganggap user membaca dari halaman terakhir yang tersimpan (**Y**)
     langsung menuju halaman terakhir buku (**Total Pages**).
     
     **Algoritma:**
     1. Set **X (Target)** = `book.totalPages`.
     2. Hitung **Z (Delta)** = `totalPages` - `currentPage`.
     3. Update status buku jadi `.finished` dan halaman mentok ke akhir.
     4. Catat `ReadingSession` sebesar **Z** (sisa halaman yang belum terbaca).
     
     - Parameter book: Buku yang ingin ditamatkan.
     */
    // MARK: - Quick Finish
    func finishBook(_ book: Book) {
        print("🖨️ [BookService] Force Finish Book: \(book.title)")
        
        let x = book.totalPages
        let y = book.currentPage
        let z = x - y
        
        book.currentPage = x
        book.status = .finished
        book.lastInteraction = Date()
        
        if z > 0 {
            let session = ReadingSession(date: Date(), pagesReadCount: z)
            session.book = book
            modelContext.insert(session)
            print("   📝 Added closing session: +\(z) pages")
        }
        
        try? modelContext.save()
        print("   ✅ Book marked as FINISHED.")
    }

    @MainActor
    func updateBook(_ book: Book) {
        book.lastInteraction = Date()
        do {
            try modelContext.save()
        } catch {
            print("   ❌ Failed to save book: \(error)")
        }
    }
    
    // MARK: - Gamification Specific Fetchers
    @MainActor
    func fetchAllBooks() async throws -> [Book] {
        let descriptor = FetchDescriptor<Book>()
        return try modelContext.fetch(descriptor)
    }

    @MainActor
    func fetchAllReadingSessions() async throws -> [ReadingSession] {
        let descriptor = FetchDescriptor<ReadingSession>()
        return try modelContext.fetch(descriptor)
    }
}
