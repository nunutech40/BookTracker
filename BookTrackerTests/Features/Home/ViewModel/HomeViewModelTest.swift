
import XCTest
@testable import BookTracker

/**
 `HomeViewModelTests`
 
 Test suite untuk `HomeViewModel`.
 
 **Tujuan Utama Pengujian:**
 1. **Memverifikasi State Awal (Initial State):** Memastikan `ViewModel` dimulai dengan state yang bersih dan dapat diprediksi. Ini penting untuk mencegah bug yang tidak terduga saat `View` pertama kali dimuat.
 2. **Memvalidasi Logika Bisnis:** Menguji logika inti seperti `refreshData` dan perhitungan `streak` untuk memastikan fungsionalitas utama berjalan sesuai harapan.
 3. **Menguji Alur Interaksi Pengguna:** Mensimulasikan tindakan pengguna (seperti mengupdate progress baca) dan memverifikasi bahwa `ViewModel` merespons dengan benar.
 4. **Memastikan Isolasi (Isolation):** Dengan menggunakan `MockBookService`, kita menguji `HomeViewModel` secara terisolasi dari `BookService` yang asli. Ini memastikan bahwa kegagalan tes benar-benar disebabkan oleh `ViewModel`, bukan oleh `Service` atau database.
 
 **Struktur Pengujian:**
 - **Given:** Menyiapkan kondisi awal, seperti state `ViewModel` atau data palsu di `MockBookService`.
 - **When:** Menjalankan metode yang ingin diuji (misalnya, `refreshData()`).
 - **Then:** Memeriksa hasil (state `ViewModel` atau interaksi dengan `mock`) menggunakan `XCTAssert`.
 */
@MainActor
class HomeViewModelTests: XCTestCase {

    var viewModel: HomeViewModel!
    var mockBookService: MockBookService!

    // MARK: - Setup & Teardown
    
    /// `setUp` dipanggil sebelum setiap metode tes dijalankan.
    /// Digunakan untuk mereset `ViewModel` dan `Mock` ke kondisi awal yang bersih.
    override func setUp() {
        super.setUp()
        mockBookService = MockBookService()
        viewModel = HomeViewModel(bookService: mockBookService)
    }

    /// `tearDown` dipanggil setelah setiap metode tes selesai.
    /// Digunakan untuk membersihkan resource agar tidak ada state yang bocor antar tes.
    override func tearDown() {
        viewModel = nil
        mockBookService = nil
        super.tearDown()
    }

    // MARK: - 1. Pengujian State Awal (Initialization)
    
    /// **Apa yang diuji:** Memastikan `isLoading` bernilai `true` saat `ViewModel` pertama kali dibuat.
    /// **Mengapa:** `View` bergantung pada `isLoading` untuk menampilkan `ProgressView`. State awal yang salah dapat menyebabkan UI yang salah ditampilkan.
    func test_initialState_isLoadingShouldBeTrue() {
        XCTAssertTrue(viewModel.isLoading, "State awal 'isLoading' harus true untuk menampilkan loading indicator.")
    }

    /// **Apa yang diuji:** Memastikan `heatmapData` kosong saat `ViewModel` diinisialisasi.
    /// **Mengapa:** Data harusnya baru dimuat setelah `refreshData` dipanggil, bukan saat inisialisasi.
    func test_initialState_heatmapDataShouldBeEmpty() {
        XCTAssertTrue(viewModel.heatmapData.isEmpty, "State awal 'heatmapData' harus kosong.")
    }

    /// **Apa yang diuji:** Memastikan `currentStreak` adalah 0 pada awalnya.
    /// **Mengapa:** `Streak` hanya boleh dihitung setelah data dimuat. Nilai awal yang non-nol akan menampilkan data yang salah kepada pengguna.
    func test_initialState_currentStreakShouldBeZero() {
        XCTAssertEqual(viewModel.currentStreak, 0, "State awal 'currentStreak' harus 0.")
    }

    // MARK: - 2. Pengujian Refresh Data
    
    /// **Apa yang diuji:** Memastikan `isLoading` menjadi `false` setelah `refreshData` selesai.
    /// **Mengapa:** Ini adalah sinyal bagi `View` untuk berhenti menampilkan `ProgressView` dan menampilkan konten utama.
    func test_refreshData_shouldSetIsLoadingToFalse() async {
        // Given
        viewModel.isLoading = true

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertFalse(viewModel.isLoading, "'isLoading' harus false setelah data berhasil dimuat.")
    }

    /// **Apa yang diuji:** Memastikan `refreshData` memanggil metode `fetchReadingHeatmap` pada `BookService`.
    /// **Mengapa:** Ini memverifikasi bahwa `ViewModel` mendelegasikan tugas pengambilan data ke `Service` dengan benar.
    func test_refreshData_shouldFetchHeatmapData() async {
        // When
        await viewModel.refreshData()

        // Then
        XCTAssertTrue(mockBookService.fetchReadingHeatmapCalled, "Metode 'fetchReadingHeatmap' pada service harus dipanggil.")
    }

    /// **Apa yang diuji:** Memastikan `heatmapData` di `ViewModel` diperbarui dengan data yang dikembalikan oleh `Service`.
    /// **Mengapa:** Ini memastikan bahwa data yang diterima dari `Service` benar-benar digunakan untuk memperbarui `state` UI.
    func test_refreshData_shouldUpdateHeatmapData() async {
        // Given
        let testData = [Date(): 5]
        mockBookService.heatmapData = testData

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertEqual(viewModel.heatmapData, testData, "ViewModel's heatmapData harus diperbarui dari data yang disediakan service.")
    }

    // MARK: - 3. Pengujian Logika Perhitungan Streak
    
    /// **Apa yang diuji:** Jika tidak ada data baca (`heatmapData` kosong), `currentStreak` harus 0.
    /// **Mengapa:** Ini adalah kasus dasar (base case) yang harus ditangani dengan benar.
    func test_calculateStreak_noReadingData_streakShouldBeZero() async {
        // Given
        mockBookService.heatmapData = [:]

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertEqual(viewModel.currentStreak, 0, "Streak harus 0 jika tidak ada data baca.")
    }

    /// **Apa yang diuji:** Jika hari baca terakhir lebih dari satu hari yang lalu, `streak` harus direset menjadi 0.
    /// **Mengapa:** Aturan `streak` adalah harus berurutan. Tes ini memastikan `streak` yang putus direset dengan benar.
    func test_calculateStreak_lastReadMoreThanADayAgo_streakShouldBeZero() async {
        // Given
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        mockBookService.heatmapData = [twoDaysAgo: 10]

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertEqual(viewModel.currentStreak, 0, "Streak harus 0 jika hari baca terakhir lebih dari sehari yang lalu.")
    }
    
    /// **Apa yang diuji:** Jika hari baca terakhir adalah kemarin, `streak` harus 1.
    /// **Mengapa:** Ini menguji kasus umum di mana pengguna mempertahankan `streak` mereka.
    func test_calculateStreak_lastReadYesterday_streakShouldBeOne() async {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        mockBookService.heatmapData = [yesterday: 10]

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertEqual(viewModel.currentStreak, 1, "Streak harus 1 jika hari baca terakhir adalah kemarin.")
    }
    
    /// **Apa yang diuji:** Jika pengguna membaca hari ini (dan tidak kemarin), `streak` harus 1.
    /// **Mengapa:** Memastikan `streak` baru dimulai dengan benar.
    func test_calculateStreak_lastReadToday_streakShouldBeOne() async {
        // Given
        let today = Date()
        mockBookService.heatmapData = [today: 10]
        
        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertEqual(viewModel.currentStreak, 1, "Streak harus 1 jika hari baca terakhir adalah hari ini.")
    }

    /// **Apa yang diuji:** Perhitungan `streak` yang benar untuk beberapa hari membaca berturut-turut.
    /// **Mengapa:** Ini adalah skenario kasus ideal dan paling penting untuk fungsionalitas `streak`.
    func test_calculateStreak_consecutiveDays_streakShouldBeCorrect() async {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        mockBookService.heatmapData = [
            today: 5,
            yesterday: 10,
            twoDaysAgo: 15
        ]

        // When
        await viewModel.refreshData()

        // Then
        XCTAssertEqual(viewModel.currentStreak, 3, "Streak harus 3 untuk 3 hari baca berturut-turut.")
    }
    
    /// **Apa yang diuji:** `Streak` dihitung dengan benar jika ada jeda dalam riwayat membaca.
    /// **Mengapa:** Menguji skenario "putus-sambung" untuk memastikan logika tidak salah menghitung hari yang tidak berurutan.
    func test_calculateStreak_nonConsecutiveDays_streakShouldBeCorrect() async {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!

        mockBookService.heatmapData = [
            today: 5,
            twoDaysAgo: 15,
            threeDaysAgo: 20
        ]

        // When
        await viewModel.refreshData()
        
        // Then
        XCTAssertEqual(viewModel.currentStreak, 1, "Streak harus 1 jika hari ini membaca, tapi kemarin tidak.")
    }


    // MARK: - 4. Pengujian Interaksi Pengguna (Submit Progress)

    /// **Apa yang diuji:** Memastikan `updateProgress` pada `Service` dipanggil dengan buku dan halaman yang benar.
    /// **Mengapa:** Memverifikasi bahwa input pengguna dari `View` diteruskan dengan benar ke lapisan `Service`.
    func test_onPageInputSubmit_shouldUpdateProgress() async {
        // Given
        let book = Book(title: "Test Book", author: "Author", totalPages: 100)
        viewModel.selectedBook = book
        let newPage = 50

        // When
        await viewModel.onPageInputSubmit(page: newPage)

        // Then
        XCTAssertTrue(mockBookService.updateProgressCalled, "Metode 'updateProgress' pada service harus dipanggil.")
        XCTAssertEqual(mockBookService.updatedBook?.id, book.id, "Buku yang benar harus diupdate.")
        XCTAssertEqual(mockBookService.updatedNewPage, newPage, "Halaman baru yang benar harus diteruskan.")
    }

    /// **Apa yang diuji:** Memastikan `refreshData` dipanggil setelah progress diupdate.
    /// **Mengapa:** UI (seperti heatmap dan streak) harus diperbarui secara otomatis setelah pengguna mengubah data.
    func test_onPageInputSubmit_shouldRefreshData() async {
        // Given
        viewModel.selectedBook = Book(title: "Test", author: "Author", totalPages: 100)

        // When
        await viewModel.onPageInputSubmit(page: 50)

        // Then
        XCTAssertTrue(mockBookService.fetchReadingHeatmapCalled, "'refreshData' harus memicu pemanggilan fetch heatmap baru.")
    }

    /// **Apa yang diuji:** `selectedBook` di-reset menjadi `nil` setelah progress diupdate.
    /// **Mengapa:** Ini adalah perilaku yang diharapkan untuk menutup `Sheet` atau `View` input progress secara otomatis.
    func test_onPageInputSubmit_shouldSetSelectedBookToNil() async {
        // Given
        viewModel.selectedBook = Book(title: "Test", author: "Author", totalPages: 100)

        // When
        await viewModel.onPageInputSubmit(page: 50)

        // Then
        XCTAssertNil(viewModel.selectedBook, "'selectedBook' harus nil setelah progress di-submit untuk menutup sheet.")
    }
}


/**
 `MockBookService`
 
 **Tujuan:**
 Kelas ini adalah "kembaran palsu" dari `BookService` yang asli. Tujuannya adalah untuk menggantikan `BookService` selama pengujian `HomeViewModel`.
 
 **Mengapa ini Penting?**
 1. **Kecepatan:** Tidak perlu mengakses database asli (SwiftData) yang lambat.
 2. **Prediktabilitas:** Kita bisa mengontrol data yang dikembalikan secara pasti (misalnya, `heatmapData`) untuk menguji skenario tertentu.
 3. **Isolasi:** Jika tes gagal, kita tahu masalahnya ada di `HomeViewModel`, bukan di `BookService`.
 
 **Cara Kerja:**
 - **`BookServiceProtocol`:** `Mock` ini mengimplementasikan `BookServiceProtocol`, sama seperti `BookService` asli. Ini memungkinkan `HomeViewModel` menerima `mock` ini tanpa tahu bedanya.
 - **`...Called` Flags:** Variabel boolean seperti `fetchReadingHeatmapCalled` digunakan untuk melacak apakah sebuah metode dipanggil oleh `ViewModel`.
 - **Properti Data:** Properti seperti `heatmapData` memungkinkan kita "menyuntikkan" data palsu ke dalam `ViewModel` untuk pengujian.
 */
class MockBookService: BookServiceProtocol {
    var books: [Book] = []
    var heatmapData: [Date: Int] = [:]

    var fetchReadingHeatmapCalled = false
    var updateProgressCalled = false

    var updatedBook: Book?
    var updatedNewPage: Int?
    
    func fetchReadingHeatmap() -> [Date: Int] {
        fetchReadingHeatmapCalled = true
        return heatmapData
    }

    func updateProgress(for book: Book, newPage: Int) {
        updateProgressCalled = true
        updatedBook = book
        updatedNewPage = newPage
        
        // Mensimulasikan `Service` yang menambahkan data baca baru,
        // yang akan mempengaruhi perhitungan streak pada panggilan `refreshData` berikutnya.
        let today = Calendar.current.startOfDay(for: Date())
        heatmapData[today, default: 0] += 1
    }
}
