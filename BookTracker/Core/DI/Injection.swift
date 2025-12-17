//
//  Injection.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//

import Foundation
import SwiftData

final class Injection {

    static let shared = Injection()

    private init() {}

    @MainActor
    func provideHomeViewModel(modelContext: ModelContext, book: Book? = nil) -> HomeViewModel {
        let bookService = provideBookService(modelContext: modelContext)
        return HomeViewModel(bookService: bookService)
    }
    
    func provideBookService(modelContext: ModelContext) -> BookService {
        return BookService(modelContext: modelContext)
    }

    func provideGoogleBooksService() -> GoogleBooksService {
        return GoogleBooksService()
    }
    
    @MainActor
    func provideBookEditorViewModel(modelContext: ModelContext, book: Book? = nil) -> BookEditorViewModel {
        let googleBookService = provideGoogleBooksService()
        let bookService = provideBookService(modelContext: modelContext)
        return BookEditorViewModel(googleBookService: googleBookService, bookService: bookService, book: book)
    }
    
    @MainActor
    func provideProfileViewModel(modelContext: ModelContext) -> ProfileViewModel {
        let bookService = provideBookService(modelContext: modelContext)
        return ProfileViewModel(bookService: bookService)
    }
}
