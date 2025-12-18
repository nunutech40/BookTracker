//
//  BookServiceProtocol.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 18/12/25.
//

import Foundation

protocol BookServiceProtocol {
    func fetchReadingHeatmap() -> [Date: Int]
    func updateProgress(for book: Book, newPage: Int)
}
