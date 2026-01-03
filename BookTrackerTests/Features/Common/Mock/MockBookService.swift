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
    public func addBook(from apiBook: BookTracker.GoogleBookItem, coverData: Data?) {
        addBookFromApiCalled = true
    }
    
    public var heatmapData: [Date: Int] = [:]
    public var fetchReadingHeatmapCalled = false
    public var updateProgressCalled = false
    public var addBookCalled = false
    public var deleteBookCalled = false
    public var finishBookCalled = false
    public var addBookFromApiCalled = false
    public var updateBookCalled = false
    
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
    
    public func addBook(from book: Book) {
        addBookCalled = true
    }
    
    public func deleteBook(_ book: Book) {
        deleteBookCalled = true
    }
    
    public func finishBook(_ book: Book) {
        finishBookCalled = true
    }
    
    public func updateBook(_ book: Book) {
        updateBookCalled = true
        updatedBook = book
    }
}
