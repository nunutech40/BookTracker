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
    @State private var viewModel = HomeViewModel()
    
    @Query(filter: #Predicate<Book> { $0.status.rawValue == "reading" },
           sort: \Book.lastInteraction, order: .reverse)
    private var activeBooks: [Book]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Hero Section (Streak)
                    heroStatsSection
                    
                    // 2. Reading List
                    readingListSection
                }
                .padding() // Padding global biar gak nempel pinggir layar
            }
            .background(Color(uiColor: .systemGroupedBackground)) // Background abu halus
            .navigationTitle("Bookmarker")
            .toolbar { toolbarContent }
            .sheet(item: $viewModel.selectedBook) { book in
                updateProgressSheet(for: book)
            }
            // Sheet Add Book Dummy
            .sheet(isPresented: $viewModel.showAddBookSheet) {
                BookEditorView()
            }
        }
        .onAppear {
            viewModel.setup(context: context)
        }
    }
}

private extension HomeView {
    
    // MARK: - 1. Hero Stats (Modern Card)
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
            
            // Mini Heatmap Visual
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
    
    // MARK: - 2. Reading List (Clean Layout)
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
    
    // ... (Toolbar & Sheet logic tetep sama kayak sebelumnya)
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: navigateToAddBook) {
                Image(systemName: "plus.circle.fill") // Icon lebih bold
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
