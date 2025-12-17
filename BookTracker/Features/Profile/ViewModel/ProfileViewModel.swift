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
    private var bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    func loadHeatmapData() {
        self.heatmapData = bookService.fetchReadingHeatmap()
    }
}
