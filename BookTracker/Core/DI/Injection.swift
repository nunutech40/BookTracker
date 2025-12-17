//
//  Injection.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//

import Foundation
import SwiftData

final class Injection {
    
    // 1. Singleton Instance
    static let shared = Injection()
    
    // 2. Private Container Storage
    // Disimpan di sini biar bisa diakses internal oleh Injection
    private var container: ModelContainer?
    
    private init() {}
    
    // 3. Setup Function (Dipanggil SEKALI di App init)
    func setup(container: ModelContainer) {
        self.container = container
    }
    
    // 4. Helper untuk ambil Context dg aman
    // Kalau container belum di-setup, dia akan crash (bagus utk debugging saat development)
    @MainActor
    private var context: ModelContext {
        guard let container = container else {
            fatalError("⚠️ Injection belum di-setup! Panggil Injection.shared.setup(container:) di App init.")
        }
        return container.mainContext
    }
    
    // MARK: - Providers
    
    // Perhatikan: Parameter 'modelContext' DIHAPUS karena sudah ambil dari internal
    @MainActor
    func provideHomeViewModel() -> HomeViewModel {
        // Otomatis pakai self.context
        let bookService = provideBookService()
        return HomeViewModel(bookService: bookService)
    }
    
    @MainActor
    func provideProfileViewModel() -> ProfileViewModel {
        let bookService = provideBookService()
        return ProfileViewModel(bookService: bookService)
    }
    
    @MainActor
    func provideBookEditorViewModel(book: Book? = nil) -> BookEditorViewModel {
        let googleBookService = provideGoogleBooksService()
        let bookService = provideBookService()
        return BookEditorViewModel(googleBookService: googleBookService, bookService: bookService, book: book)
    }

    // Service Provider (Internal Helper)
    @MainActor
    private func provideBookService() -> BookService {
        return BookService(modelContext: self.context)
    }
    
    private func provideGoogleBooksService() -> GoogleBooksService {
        return GoogleBooksService()
    }
}
