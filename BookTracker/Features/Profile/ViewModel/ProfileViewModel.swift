//
//  ProfileViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//

import Foundation
import SwiftUI

@Observable
final class ProfileViewModel {
    
    // MARK: - UI State
    var heatmapData: [Date: Int] = [:]
    
    // Dependencies
    private var bookService: BookServiceProtocol
    
    init(bookService: BookServiceProtocol) {
        self.bookService = bookService
    }
    
    func loadHeatmapData() {
        self.heatmapData = bookService.fetchReadingHeatmap()
    }
    
    func getHeatmapData(forLastMonths months: Int) -> [Date: Int] {
        return bookService.fetchReadingHeatmap(forLastMonths: months)
    }
}
