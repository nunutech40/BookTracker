//
//  HomeViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

/**
 # HomeViewModel
 
 Bertugas mengatur State untuk halaman utama (HomeView).
 
 **Tanggung Jawab:**
 1. Menghubungkan View dengan `BookService`.
 2. Mengelola data visualisasi (Heatmap).
 3. Mengontrol navigasi Sheet (via `selectedBook`).
 4. Menerima input dari View dan meneruskannya ke Service.
 
 ---
 
 ## Algoritma Loading Asynchronous untuk Pengalaman Pengguna yang Mulus
 
 **Masalah:** Saat aplikasi pertama kali diluncurkan, ada jeda (lag) yang terasa sebelum UI menjadi responsif. Hal ini terjadi karena proses pengambilan data (misalnya, dari SwiftData) dan perhitungan (misalnya, `calculateStreak`) dilakukan secara sinkron pada saat inisialisasi, yang memblokir _main thread_.
 
 **Solusi:** Menerapkan strategi pemuatan data asinkron untuk memisahkan proses inisialisasi UI dari proses pemuatan data yang berat. Ini memastikan UI muncul dengan cepat dan tetap responsif.
 
 **Langkah-langkah Algoritma:**
 1.  **Inisialisasi Cepat:** `ViewModel` diinisialisasi dengan cepat tanpa melakukan pemuatan data. Sebuah _flag_ `isLoading` diatur ke `true` untuk menandakan bahwa data awal belum siap.
 2.  **Pemicu Asinkron:** Pemuatan data (`refreshData`) dipicu secara asinkron dari luar `ViewModel` (dalam kasus ini, dari `BookTrackerApp` saat aplikasi diluncurkan). Ini memungkinkan proses pemuatan berjalan di _background thread_.
 3.  **Tampilan Loading:** Selama `isLoading` bernilai `true`, `View` (HomeView) akan menampilkan indikator pemuatan (misalnya, `ProgressView`). Ini memberikan umpan balik visual kepada pengguna bahwa aplikasi sedang bekerja.
 4.  **Pembaruan State:** Setelah data berhasil dimuat di _background_, _state_ `ViewModel` (seperti `heatmapData` dan `currentStreak`) diperbarui. `isLoading` kemudian diatur ke `false`.
 5.  **Pembaruan UI:** Perubahan pada `isLoading` secara otomatis memicu `View` untuk mengganti `ProgressView` dengan konten utama yang sekarang sudah siap ditampilkan.
 
 **Manfaat:**
 - **Responsif:** Aplikasi langsung merespons input pengguna sejak awal.
 - **Pengalaman Pengguna (UX) yang Lebih Baik:** "Lag" awal disembunyikan di balik layar pemuatan yang sudah umum dikenal pengguna.
 - **Efisiensi:** Pemanfaatan _caching_ oleh SwiftData membuat pemuatan data berikutnya (misalnya, setelah menambah buku) menjadi jauh lebih cepat.
 */
@Observable
final class HomeViewModel {
    
    // MARK: - UI State
    var heatmapData: [Date: Int] = [:]
    var currentStreak: Int = 0
    
    // ALGORITMA LANGKAH 1: Inisialisasi cepat dengan state `isLoading`
    // Flag ini mengontrol apakah View harus menampilkan ProgressView atau konten utama.
    var isLoading: Bool = true
    
    // Navigation State
    var selectedBook: Book?
    var showAddBookSheet: Bool = false
    
    // Dependencies
    private var bookService: BookService
    
    // ALGORITMA LANGKAH 1 (Lanjutan): `init` hanya melakukan setup minimal.
    // Tidak ada pemanggilan `refreshData()` yang berat di sini.
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    @MainActor
    func refreshData() async {
        // Mensimulasikan latensi jaringan atau pembacaan disk yang lambat saat pertama kali.
        if isLoading {
            try? await Task.sleep(for: .milliseconds(500))
        }
        
        // ALGORITMA LANGKAH 4: Data diambil dan state ViewModel diperbarui.
        // `bookService` akan mengambil data dari SwiftData.
        // Pertama kali, ini mungkin lambat (membaca dari disk).
        // Kali berikutnya, ini cepat (membaca dari cache memori SwiftData).
        self.heatmapData = bookService.fetchReadingHeatmap()
        calculateStreak()
        
        // ALGORITMA LANGKAH 4 (Lanjutan): Setelah data siap, ubah `isLoading`.
        // Ini akan memberitahu View untuk beralih dari ProgressView ke konten utama.
        if isLoading {
            isLoading = false
        }
    }
    
    @MainActor
    func onPageInputSubmit(page: Int) async {
        guard let book = selectedBook else { return }
        
        // Menunggu proses update selesai.
        try? await Task.sleep(for: .seconds(1))
        
        bookService.updateProgress(for: book, newPage: page)
        
        // Setelah progres diupdate, panggil `refreshData` untuk memperbarui heatmap dan streak.
        // Karena data kemungkinan besar sudah ada di cache, proses ini akan berjalan sangat cepat.
        await refreshData()
        
        // Menutup sheet setelah semua proses selesai.
        selectedBook = nil
    }
    
    // MARK: - Logic Streak Calculation
    
    private func calculateStreak() {
        let readDates = heatmapData.keys.sorted(by: >)
        guard !readDates.isEmpty else {
            currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let lastReadDate = calendar.startOfDay(for: readDates[0])
        if lastReadDate != today && lastReadDate != yesterday {
            currentStreak = 0
            return
        }
        
        var streak = 0
        var currentDateToCheck = lastReadDate
        let dateSet = Set(readDates.map { calendar.startOfDay(for: $0) })
        
        while dateSet.contains(currentDateToCheck) {
            streak += 1
            currentDateToCheck = calendar.date(byAdding: .day, value: -1, to: currentDateToCheck)!
        }
        
        self.currentStreak = streak
    }
}
