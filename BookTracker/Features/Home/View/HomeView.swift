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
            .navigationTitle("Bookmarker")
            .toolbar { toolbarContent }
            .sheet(item: $viewModel.selectedBook) { book in
                updateProgressSheet(for: book)
            }
            // Sheet Add Book
            .sheet(isPresented: $viewModel.showAddBookSheet) {
                NavigationStack {
                    BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel(modelContext: context))
                }
            }
        }
    }
}

private extension HomeView {
    
    // MARK: - 1. Hero Stats
    var heroStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Streak")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.yellow)
                        
                        Text(viewModel.currentStreak > 0 ? "\(viewModel.currentStreak) Days" : "Start Today")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
            }
            
            if !viewModel.heatmapData.isEmpty {
                Chart {
                    ForEach(viewModel.heatmapData.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                        BarMark(
                            x: .value("Date", date),
                            y: .value("Pages", count)
                        )
                        .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .frame(height: 40)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
            }
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
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
        UpdateProgressSheet(book: book) { newPage in
            viewModel.onPageInputSubmit(page: newPage)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    func navigateToAddBook() {
        viewModel.showAddBookSheet = true
    }
}
