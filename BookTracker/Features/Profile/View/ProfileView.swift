//
//  ProfileView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @State var viewModel: ProfileViewModel
    
    // State for Share Sheet
    @State private var showShareSheet = false
    @State private var shareableImage: UIImage?
    @State private var shareCard: ShareCardView?

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text(String(localized: "Reading Activity (Last 12 Months)"))) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Header Stats
                        HStack {
                            VStack(alignment: .leading) {
                                Text(String(localized: "Total Pages"))
                                    .font(.caption).foregroundStyle(.secondary)
                                Text("\(totalPagesRead())")
                                    .font(.headline).bold()
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(localized: "Active Days"))
                                    .font(.caption).foregroundStyle(.secondary)
                                Text("\(viewModel.heatmapData.count)")
                                    .font(.headline).bold()
                            }
                        }
                        
                        // THE GRID (KOTAK-KOTAK)
                        GitHubHeatmapView(data: viewModel.heatmapData)
                            .frame(height: 160) // Tinggi pas buat 7 kotak + Tooltip area
                        
                        // Legend
                        HStack {
                            Text(String(localized: "Less"))
                            RoundedRectangle(cornerRadius: 2).fill(Color.gray.opacity(0.2)).frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.green.opacity(0.4)).frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.green.opacity(0.7)).frame(width: 12, height: 12)
                            RoundedRectangle(cornerRadius: 2).fill(Color.green).frame(width: 12, height: 12)
                            Text(String(localized: "More"))
                        }
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: 2. MY COLLECTIONS
                Section(header: Text(String(localized: "Collections"))) {
                    NavigationLink(destination: HistoryView()) {
                        Label(String(localized: "Finished Books"), systemImage: "trophy.fill")
                            .foregroundStyle(.orange)
                    }
                }
                
                // MARK: 3. APP INFO
                Section(header: Text(String(localized: "App Info"))) {
                    NavigationLink(destination: AboutView()) {
                        Label(String(localized: "About BookTracker"), systemImage: "info.circle.fill")
                            .foregroundStyle(.blue)
                    }
                    
                    NavigationLink(destination: SupportDeveloperView()) {
                        Label(String(localized: "Dukung Developer"), systemImage: "hand.raised.fill")
                            .foregroundStyle(.pink)
                    }
                }
            }
            .navigationTitle(String(localized: "Profile"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        renderShareCard()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = shareableImage {
                    ActivityView(activityItems: [image, "Check out my reading progress on BookTracker!"])
                }
            }
            .background(
                Group {
                    if let shareCard = shareCard {
                        shareCard
                            .opacity(0)
                            .frame(width: 0, height: 0)
                    }
                }
            )
            .onAppear {
                viewModel.loadHeatmapData()
                let data = viewModel.getHeatmapData(forLastMonths: 6)
                self.shareCard = ShareCardView(heatmapData: data)
            }
        }
    }
    
    func totalPagesRead() -> Int {
        viewModel.heatmapData.values.reduce(0, +)
    }
    
    @MainActor
    private func renderShareCard() {
        if let shareCard = shareCard {
            let renderer = ImageRenderer(content: shareCard)
            renderer.scale = UIScreen.main.scale
            
            if let image = renderer.uiImage {
                self.shareableImage = image
                self.showShareSheet = true
            }
        }
    }
}

// MARK: - COMPONENT: INTERACTIVE HEATMAP
struct GitHubHeatmapView: View {
    let data: [Date: Int]
    
    // Grid Layout: 7 Baris (Minggu - Sabtu)
    let rows = Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7)
    
    // State buat Tooltip
    @State private var selectedDate: Date?
    @State private var selectedPages: Int?
    
    // Generate array tanggal 52 minggu (Setahun)
    var calendarDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        // 53 minggu x 7 hari = ~371 hari (biar cover full setahun)
        var days: [Date] = []
        // Kita balik urutannya biar start dari setahun lalu sampai hari ini
        for i in (0..<371).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        return days
    }
    
    var body: some View {
        ZStack(alignment: .top) { // ZStack buat numpuk Tooltip
            
            // 1. SCROLLABLE GRID
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 4) {
                    ForEach(calendarDays, id: \.self) { date in
                        // Kotak Individu
                        RoundedRectangle(cornerRadius: 2)
                            .fill(getColor(for: date))
                            .frame(width: 12, height: 12)
                        // INTERAKSI TAP
                            .overlay {
                                // Kasih border kalau lagi dipilih
                                if selectedDate == date {
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.black, lineWidth: 2)
                                }
                            }
                            .onTapGesture {
                                // Logic Tooltip: Tap untuk Select / Deselect
                                if selectedDate == date {
                                    selectedDate = nil // Tutup kalau di-tap lagi
                                } else {
                                    selectedDate = date
                                    selectedPages = data[date] ?? 0
                                    // Haptic Feedback biar kerasa "klik"
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                            }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 40) // Kasih ruang buat Tooltip di atas
            }
            .defaultScrollAnchor(.trailing) // Start dari Hari Ini (Kanan)
            
            // 2. TOOLTIP (Muncul kalau ada selectedDate)
            if let date = selectedDate {
                VStack(spacing: 4) {
                    Text("\(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    if let pages = selectedPages, pages > 0 {
                        Text(String(format: NSLocalizedString("%lld pages read", comment: ""), pages))
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.primary)
                    } else {
                        Text(String(localized: "No reading activity"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .shadow(radius: 4)
                .transition(.scale.combined(with: .opacity)) // Animasi muncul
                .onTapGesture {
                    withAnimation { selectedDate = nil } // Tap tooltip buat tutup
                }
            }
        }
    }
    
    // Logic Warna ala GitHub
    func getColor(for date: Date) -> Color {
        let count = data[date] ?? 0
        
        if count == 0 { return Color.gray.opacity(0.2) }      // Kosong
        if count < 20 { return Color.green.opacity(0.3) }     // Dikit
        if count < 50 { return Color.green.opacity(0.6) }     // Sedang
        if count < 100 { return Color.green.opacity(0.8) }    // Banyak
        return Color.green                                    // Gila Baca
    }
}
