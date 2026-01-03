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
    func addBook(from book: Book)
    func deleteBook(_ book: Book)
    func finishBook(_ book: Book)
    func addBook(from apiBook: GoogleBookItem, coverData: Data?)
    func updateBook(_ book: Book)
}
