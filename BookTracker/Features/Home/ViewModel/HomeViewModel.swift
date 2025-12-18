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
    var currentStreak: Int = 0
    var isLoading: Bool = true
    
    // Navigation State
    var selectedBook: Book?
    var showAddBookSheet: Bool = false
    
    // Dependencies
    private var bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    @MainActor
    func refreshData() async {
        // Simulate background work for initial load
        if isLoading {
            try? await Task.sleep(for: .milliseconds(500))
        }
        
        self.heatmapData = bookService.fetchReadingHeatmap()
        calculateStreak()
        
        if isLoading {
            isLoading = false
        }
    }
    
    @MainActor
    func onPageInputSubmit(page: Int) async {
        guard let book = selectedBook else { return }
        
        try? await Task.sleep(for: .seconds(1))
        
        bookService.updateProgress(for: book, newPage: page)
        await refreshData()
        
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
