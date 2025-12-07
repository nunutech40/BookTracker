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
final class BookService {
    
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
    func updateProgress(for book: Book, newPage: Int) {
        let x = newPage
        let y = book.currentPage
        
        // 1. Hitung Delta (Berapa halaman yang dibaca barusan?)
        var z = x - y
        
        // 2. Validasi Negative Value
        // Jika user merevisi halaman ke belakang (misal salah input),
        // kita update posisinya, tapi TIDAK dianggap sebagai "membaca" (Z=0).
        if z < 0 { z = 0 }
        
        // 3. Update State Buku (Live Object Manipulation)
        book.currentPage = x
        book.lastInteraction = Date() // Update timestamp agar buku naik ke urutan teratas list
        
        // 4. Auto-Switch Status (Reading -> Finished)
        if book.currentPage >= book.totalPages {
            book.currentPage = book.totalPages
            book.status = .finished
        } else {
            // Jika user membaca ulang buku tamat, kembalikan status ke reading
            book.status = .reading
        }
        
        // 5. Create History (ReadingSession)
        // Hanya catat sesi jika ada progress positif (Z > 0)
        if z > 0 {
            let session = ReadingSession(date: Date(), pagesReadCount: z)
            session.book = book // Link relasi (One-to-Many)
            modelContext.insert(session)
        }
        
        // 6. Persist to Disk
        // Memastikan perubahan tersimpan permanen saat itu juga.
        try? modelContext.save()
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
    func fetchReadingHeatmap() -> [Date: Int] {
        let descriptor = FetchDescriptor<ReadingSession>()
        
        // Fail-safe: Return kosong jika fetch gagal
        guard let sessions = try? modelContext.fetch(descriptor) else { return [:] }
        
        // Grouping by Date (Mengabaikan jam/menit, fokus ke Tanggal saja)
        let grouped = Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.date)
        }
        
        // Summing pages per day
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
        // Mapping Data: API -> Local Model
        let title = apiBook.volumeInfo.title
        let totalPages = apiBook.volumeInfo.pageCount ?? 100 // Fallback default jika API null
        let author = apiBook.volumeInfo.authors?.first ?? "Unknown"
        
        let newBook = Book(title: title, totalPages: totalPages, coverImageData: coverData)
        
        // Opsional: Uncomment jika Model Book sudah punya properti author
        // newBook.author = author
        
        // Insert & Save
        modelContext.insert(newBook)
        try? modelContext.save()
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
    func finishBook(_ book: Book) {
        let x = book.totalPages
        let y = book.currentPage
        
        // 1. Hitung sisa halaman yang "dihabiskan" saat ini
        let z = x - y
        
        // 2. Update State Buku
        book.currentPage = x
        book.status = .finished // Force status ke finished
        book.lastInteraction = Date()
        
        // 3. Create History (ReadingSession)
        // Catat sisa halaman sebagai progress sesi ini
        if z > 0 {
            let session = ReadingSession(date: Date(), pagesReadCount: z)
            session.book = book
            modelContext.insert(session)
        }
        
        // 4. Save
        try? modelContext.save()
    }
}
