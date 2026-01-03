//
//  HomeView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData
import Charts

/**
 ## Peran HomeView dalam Arsitektur Loading Asinkron
 
 `HomeView` bertanggung jawab untuk menampilkan UI berdasarkan state yang dikelola oleh `HomeViewModel`. View ini dirancang untuk menjadi "bodoh" (_dumb_), artinya ia tidak melakukan logika bisnis atau pemuatan data secara langsung.
 
 **Algoritma dari Sisi View:**
 1.  **ALGORITMA LANGKAH 3: Menampilkan UI Loading.**
     Saat `HomeView` pertama kali muncul, ia akan memeriksa `viewModel.isLoading`. Jika `true`, `View` akan menampilkan `ProgressView`. Ini adalah implementasi dari _splash screen_ atau layar pemuatan data awal.
 
 2.  **ALGORITMA LANGKAH 5: Menampilkan Konten Utama.**
     `HomeViewModel` akan mengubah `isLoading` menjadi `false` setelah data siap. Karena `viewModel` adalah `@Observable`, perubahan ini secara otomatis akan membuat `HomeView` me-render ulang (_re-render_). `ZStack` kemudian akan menampilkan `ScrollView` yang berisi konten utama.
 
 3.  **Pemuatan Data Lanjutan (Refresh).**
     - **Saat App Muncul:** Pemuatan data awal tidak lagi dipicu oleh `.onAppear` di `HomeView`. Sebaliknya, itu dipicu saat aplikasi pertama kali diluncurkan di `BookTrackerApp.swift`. Ini memastikan data mulai dimuat bahkan sebelum `HomeView` muncul, membuat transisi lebih mulus.
     - **Setelah Menambah Buku:** `onDisappear` pada sheet `BookEditorView` digunakan untuk memicu `refreshData()`. Ini memastikan bahwa daftar buku dan statistik di `HomeView` selalu yang terbaru setelah pengguna menambahkan entri baru.
 */
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State var viewModel: HomeViewModel
    
    // Data buku diambil menggunakan @Query, yang secara otomatis akan diperbarui oleh SwiftData
    // ketika ada perubahan di database.
    @Query(sort: \Book.lastInteraction, order: .reverse)
    private var allBooks: [Book]
    
    // Computed property untuk memfilter buku yang sedang dibaca.
    // Ini lebih efisien daripada menjalankan query baru.
    var activeBooks: [Book] {
        allBooks.filter { $0.status == .reading }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ALGORITMA LANGKAH 3 & 5: Pengkondisian Tampilan
                // Jika `isLoading` true, tampilkan spinner.
                // Jika false, tampilkan konten utama.
                if viewModel.isLoading {
                    ProgressView("Loading Your Library...")
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            heroStatsSection
                            readingListSection
                        }
                        .padding()
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                }
            }
            .navigationTitle("Bookmarker")
            .toolbar { toolbarContent }
            .sheet(item: $viewModel.selectedBook) { book in
                updateProgressSheet(for: book)
            }
            // Sheet untuk menambah buku baru
            .sheet(isPresented: $viewModel.showAddBookSheet) {
                NavigationStack {
                    BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel())
                }
                // ALGORITMA LANGKAH LANJUTAN: Refresh data setelah ada kemungkinan perubahan.
                .onDisappear {
                    Task {
                        await viewModel.refreshData()
                    }
                }
            }
        }
    }
}

private extension HomeView {
    
    // MARK: - Subviews
    
    var heroStatsSection: some View {
        HStack {
            if viewModel.currentStreak > 0 {
                activeStreakContent
            } else {
                emptyStreakContent
            }
            
            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    var activeStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                
                Text("CURRENT STREAK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            let dayText = LocalizedStringResource(viewModel.currentStreak == 1 ? "Day" : "Days")
            Text("\(viewModel.currentStreak) \(dayText)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Text("You're on fire! Keep the momentum going.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var emptyStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                
                Text("DAILY GOAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Text("0 Days")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            
            Text("Read just 1 page today to start your streak.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    var readingListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Now")
                .font(.title3)
                .bold()
                .padding(.horizontal, 4)
            
            if activeBooks.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(activeBooks) { book in
                        bookRow(for: book)
                    }
                }
            }
        }
    }
    
    func bookRow(for book: Book) -> some View {
        BookCardView(
            book: book,
            onTapUpdate: {
                viewModel.selectedBook = book
            },
            onTapCamera: {
                // TODO: Implement camera functionality
            }
        )
    }
    
    var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.gray.opacity(0.3))
            
            Text("No Active Books")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Your reading journey starts here.\nTap + to add a book.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: navigateToAddBook) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
        }
    }
    
    func updateProgressSheet(for book: Book) -> some View {
        UpdateProgressSheet(book: book, maxPage: book.totalPages) { newPage in
            await viewModel.onPageInputSubmit(page: newPage)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func navigateToAddBook() {
        viewModel.showAddBookSheet = true
    }
}
