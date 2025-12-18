//
//  HomeView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State var viewModel: HomeViewModel
    
    // 2. Kita tarik semua buku, urutkan berdasarkan interaksi terakhir.
    @Query(sort: \Book.lastInteraction, order: .reverse)
    private var allBooks: [Book]
    
    // 3. Kita filter manual di sini (Computed Property).
    // Ini 100% aman dan gak bakal error Predicate lagi.
    var activeBooks: [Book] {
        allBooks.filter { $0.status == .reading }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // 1. Hero Section (Streak)
                            heroStatsSection
                            
                            // 2. Reading List
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
            // Sheet Add Book
            .sheet(isPresented: $viewModel.showAddBookSheet) {
                NavigationStack {
                    BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel())
                }
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
    
    // MARK: - 1. Hero Stats (Clean Version)
    var heroStatsSection: some View {
        HStack {
            if viewModel.currentStreak > 0 {
                activeStreakContent // Mode: Semangat Membara 🔥
            } else {
                emptyStreakContent  // Mode: Ayo Mulai 📖
            }
            
            Spacer() // Dorong text ke kiri
        }
        .padding(24) // Padding agak gede biar lega
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
    
    // MARK: - Content Modes
    
    // Mode A: User Rajin (Validasi & Pujian)
    var activeStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label atas
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                
                Text("CURRENT STREAK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Angka Besar
            // Logic Grammar: 1 Day vs 2 Days
            let dayText = viewModel.currentStreak == 1 ? "Day" : "Days"
            
            Text("\(viewModel.currentStreak) \(dayText)")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            // Copywriting Penyemangat
            Text("You're on fire! Keep the momentum going.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true) // Biar text wrap kalau kepanjangan
        }
    }
    
    // Mode B: Belum Mulai (Ajakan Halus)
    var emptyStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label atas
            HStack(spacing: 6) {
                Image(systemName: "star.fill") // Ganti bintang biar beda feel
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                
                Text("DAILY GOAL")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            // Angka Redup
            Text("0 Days")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4)) // Dibuat redup biar user "gatal" pengen ubah
            
            // Copywriting Actionable
            Text("Read just 1 page today to start your streak.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 2. Reading List
    var readingListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Now")
                .font(.title3)
                .bold()
                .padding(.horizontal, 4)
            
            // Logic UI tetep sama, pake 'activeBooks' yang udah difilter di atas
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
                // TODO: Open Camera
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
