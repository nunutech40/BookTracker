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
 */
@Observable
final class HomeViewModel {
    
    // MARK: - UI State
    var heatmapData: [Date: Int] = [:]
    var currentStreak: Int = 0 // <-- STATE BARU: Data Streak Real
    
    // Navigation State
    var selectedBook: Book?
    var showAddBookSheet: Bool = false // <-- STATE BARU: Buat trigger sheet AddBook
    
    // Dependencies
    private var bookService: BookService?
    
    func setup(context: ModelContext) {
        self.bookService = BookService(modelContext: context)
        refreshData()
    }
    
    func refreshData() {
        guard let service = bookService else { return }
        
        // 1. Fetch Heatmap
        self.heatmapData = service.fetchReadingHeatmap()
        
        // 2. Hitung Streak dari data heatmap yang ada
        calculateStreak()
    }
    
    func onPageInputSubmit(page: Int) {
        guard let book = selectedBook else { return }
        bookService?.updateProgress(for: book, newPage: page)
        refreshData() // Refresh semua (heatmap + streak)
        selectedBook = nil
    }
    
    // MARK: - Logic Streak Calculation
    
    private func calculateStreak() {
        // Ambil semua tanggal unik yang ada session-nya
        let readDates = heatmapData.keys.sorted(by: >) // Urutkan dari terbaru
        
        guard !readDates.isEmpty else {
            currentStreak = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Cek apakah user baca hari ini atau kemarin (kalau terakhir baca 2 hari lalu, streak putus)
        let lastReadDate = calendar.startOfDay(for: readDates[0])
        
        if lastReadDate != today && lastReadDate != yesterday {
            currentStreak = 0
            return
        }
        
        // Hitung mundur
        var streak = 0
        var currentDateToCheck = lastReadDate
        
        // Ubah Array tanggal jadi Set biar pencarian O(1) alias cepet
        let dateSet = Set(readDates.map { calendar.startOfDay(for: $0) })
        
        while dateSet.contains(currentDateToCheck) {
            streak += 1
            // Mundur 1 hari ke belakang
            currentDateToCheck = calendar.date(byAdding: .day, value: -1, to: currentDateToCheck)!
        }
        
        self.currentStreak = streak
    }
}
