import SwiftUI

struct ShareableHeatmap: View {
    let data: [Date: Int]
    let months: Int
    
    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let today = Date()
        var days: [Date] = []
        let daysInMonths = months * 30
        for i in (0..<daysInMonths).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                days.append(calendar.startOfDay(for: date))
            }
        }
        return days
    }
    
    private var monthLabels: [String] {
        let calendar = Calendar.current
        var labels: [String] = []
        for i in (0..<months).reversed() {
            if let date = calendar.date(byAdding: .month, value: -i, to: Date()) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM"
                labels.append(dateFormatter.string(from: date))
            }
        }
        return labels
    }
    
    let rows = Array(repeating: GridItem(.fixed(9), spacing: 2), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach(monthLabels, id: \.self) { label in
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            LazyHGrid(rows: rows, spacing: 2) {
                ForEach(calendarDays, id: \.self) { date in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(getColor(for: date))
                        .frame(width: 9, height: 9)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getColor(for date: Date) -> Color {
        let count = data[date] ?? 0
        
        if count == 0 { return Color.white.opacity(0.15) }
        if count < 20 { return Color.yellow.opacity(0.4) }
        if count < 50 { return Color.yellow.opacity(0.7) }
        return Color.yellow
    }
}
