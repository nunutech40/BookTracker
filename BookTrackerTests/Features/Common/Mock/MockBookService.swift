//
//  MockBookService.swift
//  BookTrackerTests
//
//  Created by Nunu Nugraha on 18/12/25.
//

import Foundation
@testable import BookTracker

/**
 `MockBookService`
 
 Versi palsu dari `BookService` yang digunakan khusus untuk testing di seluruh fitur.
 Kelas ini mengadopsi `BookServiceProtocol` sehingga bisa menggantikan `BookService` yang asli saat menguji `ViewModel`.
 
 **Fungsi Utama:**
 - **`fetchReadingHeatmapCalled` & `updateProgressCalled`:** "Spy" untuk merekam apakah sebuah metode pernah dipanggil.
 - **`heatmapData`:** Properti yang bisa diatur untuk mengontrol data apa yang akan "dikembalikan" oleh mock.
 - **`updatedBook`, `updatedNewPage`:** Properti untuk memverifikasi argumen yang dikirim ke metode `updateProgress`.
 */
public class MockBookService: BookServiceProtocol {
    public var heatmapData: [Date: Int] = [:]
    public var fetchReadingHeatmapCalled = false
    public var updateProgressCalled = false
    
    public var updatedBook: Book?
    public var updatedNewPage: Int?
    
    public init() {}
    
    public func fetchReadingHeatmap() -> [Date: Int] {
        fetchReadingHeatmapCalled = true
        return heatmapData
    }
    
    public func updateProgress(for book: Book, newPage: Int) {
        updateProgressCalled = true
        updatedBook = book
        updatedNewPage = newPage
        
        // Mensimulasikan `Service` yang menambahkan data baca baru,
        // yang akan mempengaruhi perhitungan streak pada panggilan `refreshData` berikutnya.
        let today = Calendar.current.startOfDay(for: Date())
        heatmapData[today, default: 0] += 1
    }
}
