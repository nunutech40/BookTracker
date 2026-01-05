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
    
    // State for Data Scanner & Permissions
    @State private var showScanner = false
    @State private var scannedText = ""
    @State private var bookToScan: Book?
    @StateObject private var permissionManager = PermissionManager()
    @State private var showPermissionDenied = false

    @Query(sort: \Book.lastInteraction, order: .reverse)
    private var allBooks: [Book]
    
    var activeBooks: [Book] {
        allBooks.filter { $0.status == .reading }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView(String(localized: "Loading Your Library..."))
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
            .navigationTitle(String(localized: "Bookmarker"))
            .toolbar { toolbarContent }
            .sheet(item: $viewModel.selectedBook) { book in
                updateProgressSheet(for: book)
            }
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
            .sheet(isPresented: $showScanner) {
                DataScannerView(recognizedText: $scannedText)
                    .onDisappear {
                        if !scannedText.isEmpty {
                            viewModel.scannedPage = scannedText
                            viewModel.selectedBook = bookToScan
                        }
                        // Reset scanner state
                        bookToScan = nil
                        scannedText = ""
                    }
            }
            .sheet(isPresented: $showPermissionDenied) {
                PermissionDeniedView(permissionType: .camera)
            }
        }
    }
    
    // MARK: - Subviews & Builders
    
    private var heroStatsSection: some View {
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
    
    private var activeStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                Text(String(localized: "CURRENT STREAK"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            let dayText = String(localized: "\(viewModel.currentStreak) Day(s)")
            Text(dayText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(String(localized: "You're on fire! Keep the momentum going."))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
            
            // New: Display the LAST unlocked achievement
            if let lastAchievement = viewModel.unlockedAchievements.last {
                Divider().background(.white.opacity(0.5))
                
                HStack(spacing: 6) {
                    Image(systemName: lastAchievement.icon)
                        .foregroundStyle(.yellow)
                        .font(.caption.bold())
                    Text(lastAchievement.title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Text(lastAchievement.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var emptyStreakContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                    .font(.caption.bold())
                Text(String(localized: "DAILY GOAL"))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(String(localized: "0 Days"))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.4))
            Text(String(localized: "Read just 1 page today to start your streak."))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var readingListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Reading Now"))
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
    
    private func bookRow(for book: Book) -> some View {
        BookCardView(
            book: book,
            onTapUpdate: {
                viewModel.selectedBook = book
            },
            onTapCamera: {
                bookToScan = book
                permissionManager.requestPermission(for: .camera) { granted in
                    if granted {
                        showScanner = true
                    } else {
                        showPermissionDenied = true
                    }
                }
            }
        )
    }
    
    private var emptyStateView: some View {
        Button(action: navigateToAddBook) {
            VStack(spacing: 12) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.gray.opacity(0.3))
                Text(String(localized: "No Active Books"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(String(localized: "Your reading journey starts here.\nTap + to add a book."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain) // Use .plain to remove default button styling
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: navigateToAddBook) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private func updateProgressSheet(for book: Book) -> some View {
        // Grab the scanned page and then immediately reset it on the view model
        // so it's not accidentally used again.
        let scannedPage = viewModel.scannedPage
        DispatchQueue.main.async {
            viewModel.scannedPage = nil
        }
        
        return UpdateProgressSheet(book: book, maxPage: book.totalPages, scannedPage: scannedPage) { newPage in
            await viewModel.onPageInputSubmit(page: newPage, for: book)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func navigateToAddBook() {
        viewModel.showAddBookSheet = true
    }
}
