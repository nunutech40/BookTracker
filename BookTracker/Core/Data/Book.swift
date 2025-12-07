//
//  Book.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftData
import Foundation

enum BookStatus: String, Codable {
    case reading
    case shelf
    case finished
}

@Model
final class Book {
    var id: UUID
    var title: String
    var totalPages: Int
    var currentPage: Int
    var coverImageData: Data?
    var status: BookStatus
    var lastInteraction: Date
    
    // Relationship
    @Relationship(deleteRule: .cascade, inverse: \ReadingSession.book)
    var sessions: [ReadingSession] = []
    
    init(title: String, totalPages: Int, coverImageData: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.totalPages = totalPages
        self.currentPage = 0
        self.coverImageData = coverImageData
        self.status = .shelf
        self.lastInteraction = Date()
    }
}

@Model
final class ReadingSession {
    var id: UUID
    var date: Date
    var pagesReadCount: Int
    
    var book: Book?
    
    init(date: Date = Date(), pagesReadCount: Int) {
        self.id = UUID()
        self.date = date
        self.pagesReadCount = pagesReadCount
    }
}
