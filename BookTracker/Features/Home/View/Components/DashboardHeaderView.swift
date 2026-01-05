//
//  DashboardHeaderView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import Charts

struct DashboardHeaderView: View {
    var heatmapData: [Date: Int]
    var streak: Int // <-- Data masuk dari ViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Streak Header Dinamis
            HStack {
                if streak > 0 {
                    // Kalo ada streak
                    Label(String(format: NSLocalizedString("%d Day Streak", comment: ""), streak), systemImage: "flame.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.orange, .red)
                        .font(.headline)
                    Spacer()
                    Text(String(localized: "Keep it up!"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    // Kalo streak 0 (User baru/Belum baca)
                    Label(String(localized: "Start Reading"), systemImage: "book.fill")
                        .foregroundStyle(.blue)
                        .font(.headline)
                    Spacer()
                    Text(String(localized: "No reading data yet"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Heatmap (Tetap sama)
            Chart {
                ForEach(heatmapData.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                    RuleMark(x: .value("Date", date), yStart: 0, yEnd: 10)
                        .foregroundStyle(Color.secondary.opacity(0.1))
                    
                    BarMark(
                        x: .value("Date", date),
                        y: .value("Pages", count)
                    )
                    .foregroundStyle(Color.green.gradient)
                }
            }
            .frame(height: 50)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
