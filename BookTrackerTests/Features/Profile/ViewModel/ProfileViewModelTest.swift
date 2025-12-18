//
//  ProfileViewModelTest.swift
//  BookTrackerTests
//
//  Created by Nunu Nugraha on 18/12/25.
//

import XCTest
@testable import BookTracker

/**
 `ProfileViewModelTests`
 
 Test suite for `ProfileViewModel`.
 
 **Tujuan Utama Pengujian:**
 1. **Memverifikasi State Awal:** Memastikan `ViewModel` dimulai dengan state yang bersih dan dapat diprediksi.
 2. **Memvalidasi Pengambilan Data:** Menguji bahwa `ViewModel` dengan benar memuat data yang diperlukan dari `Service`-nya.
 3. **Memastikan Isolasi (Isolation):** Menggunakan `MockBookService` untuk mengisolasi `ProfileViewModel` dari dependensi eksternal, memastikan tes fokus pada logika `ViewModel` itu sendiri.
 
 **Struktur Pengujian:**
 - **Given:** Menyiapkan kondisi, termasuk inisialisasi `ViewModel` dengan `MockBookService`.
 - **When:** Menjalankan metode yang akan diuji (`loadHeatmapData`).
 - **Then:** Memverifikasi bahwa `state` `ViewModel` telah diperbarui dengan benar dan `Service` telah dipanggil.
 */
@MainActor
class ProfileViewModelTests: XCTestCase {

    var viewModel: ProfileViewModel!
    var mockBookService: MockBookService!

    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        mockBookService = MockBookService()
        viewModel = ProfileViewModel(bookService: mockBookService)
    }

    override func tearDown() {
        viewModel = nil
        mockBookService = nil
        super.tearDown()
    }

    // MARK: - 1. Pengujian State Awal (Initialization)
    
    /// **Apa yang diuji:** Memastikan `heatmapData` pada awalnya kosong.
    /// **Mengapa:** Data seharusnya hanya dimuat saat `loadHeatmapData` dipanggil, bukan saat inisialisasi, untuk memastikan pemuatan data yang terkontrol.
    func test_initialState_heatmapDataShouldBeEmpty() {
        XCTAssertTrue(viewModel.heatmapData.isEmpty, "Initial 'heatmapData' state should be empty.")
    }

    // MARK: - 2. Pengujian Pemuatan Data
    
    /// **Apa yang diuji:** Memastikan metode `fetchReadingHeatmap` pada `Service` dipanggil saat `loadHeatmapData` dieksekusi.
    /// **Mengapa:** Ini memverifikasi bahwa `ViewModel` mendelegasikan tugas pengambilan data ke `Service` dengan benar.
    func test_loadHeatmapData_shouldCallFetchReadingHeatmap() {
        // When
        viewModel.loadHeatmapData()

        // Then
        XCTAssertTrue(mockBookService.fetchReadingHeatmapCalled, "'fetchReadingHeatmap' should be called on the service.")
    }
    
    /// **Apa yang diuji:** Memastikan `heatmapData` di `ViewModel` diperbarui dengan data yang dikembalikan oleh `Service`.
    /// **Mengapa:** Ini memastikan bahwa data yang diterima dari `Service` benar-benar digunakan untuk memperbarui `state` UI.
    func test_loadHeatmapData_shouldUpdateHeatmapData() {
        // Given
        let testData: [Date: Int] = [
            Calendar.current.startOfDay(for: Date()): 10,
            Calendar.current.date(byAdding: .day, value: -1, to: Date())!: 5
        ]
        mockBookService.heatmapData = testData
        
        // When
        viewModel.loadHeatmapData()

        // Then
        XCTAssertEqual(viewModel.heatmapData, testData, "ViewModel's heatmapData should be updated with data from the service.")
    }
}
