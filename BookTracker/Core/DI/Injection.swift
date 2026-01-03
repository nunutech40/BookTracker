//
//  Injection.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 17/12/25.
//

import Foundation
import SwiftData

/**
 # Dependency Injection Container
 
 A centralized singleton class responsible for creating and providing all major dependencies
 (Services, ViewModels) throughout the application. This ensures that dependencies are created
 in a single, controlled environment, making the app more modular, testable, and easier to manage.
 
 ## How It Works
 1.  **Singleton Pattern:** `Injection.shared` provides a single, globally accessible instance.
 2.  **Setup:** The `setup(container:)` method MUST be called once when the app starts
 (in `BookTrackerApp.swift`) to provide the main `ModelContainer`. This container is
 then stored internally.
 3.  **Internal Context:** A private `context` property provides the main `ModelContext` to any
 provider method that needs it, ensuring all services operate on the same data context.
 4.  **Provider Methods:** Public methods like `provideHomeViewModel()` or `provideBookEditorViewModel(book:)`
 act as factories. They assemble the required dependencies (like services) and inject them
 into the ViewModels.
 
 ## How to Use
 
 ### 1. App Setup (Do this once)
 In `BookTrackerApp.swift`, during initialization, call the setup method:
 ```swift
 init() {
    Injection.shared.setup(container: sharedModelContainer)
 }
 ```
 
 ### 2. Providing a ViewModel to a View
 When creating a view that needs a ViewModel, call the corresponding provider method.
 
 **Example for creating a new book:**
 ```swift
 // No book is passed, so the ViewModel is in .create mode.
 BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel())
 ```
 
 **Example for editing an existing book:**
 ```swift
 // A book is passed, so the ViewModel is in .edit mode.
 BookEditorView(viewModel: Injection.shared.provideBookEditorViewModel(book: myBook))
 ```
 */
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
    
    /// Provides a `HomeViewModel` with its `BookService`, `GamificationService`, and `NotificationManager` dependencies automatically injected.
    @MainActor
    func provideHomeViewModel() -> HomeViewModel {
        // Otomatis pakai self.context
        let bookService = provideBookService()
        let gamificationService = provideGamificationService()
        let notificationManager = provideNotificationManager()
        return HomeViewModel(bookService: bookService, gamificationService: gamificationService, notificationManager: notificationManager)
    }
    
    /// Provides a `ProfileViewModel` with its `BookService` dependency automatically injected.
    @MainActor
    func provideProfileViewModel() -> ProfileViewModel {
        let bookService = provideBookService()
        return ProfileViewModel(bookService: bookService)
    }
    
    /// Provides a `BookEditorViewModel` for either creating a new book or editing an existing one.
    /// - Parameter book: An optional `Book`. If `nil`, the ViewModel is configured for creating a new book.
    ///                   If provided, the ViewModel is configured to edit the given book.
    @MainActor
    func provideBookEditorViewModel(book: Book? = nil) -> BookEditorViewModel {
        let googleBookService = provideGoogleBooksService()
        let bookService = provideBookService()
        return BookEditorViewModel(googleBookService: googleBookService, bookService: bookService, book: book)
    }
    
    /// Provides a `GamificationViewModel` with its `GamificationService` and `BookService` dependencies injected.
    @MainActor
    func provideGamificationViewModel() -> GamificationViewModel {
        let gamificationService = provideGamificationService()
        let bookService = provideBookService()
        return GamificationViewModel(gamificationService: gamificationService, bookService: bookService)
    }

    // MARK: - Internal Service Providers
    
    /// Provides a shared `BookService` instance, automatically using the main model context.
    @MainActor
    private func provideBookService() -> BookService {
        return BookService(modelContext: self.context)
    }
    
    /// Provides a shared `GoogleBooksService` instance.
    private func provideGoogleBooksService() -> GoogleBooksService {
        return GoogleBooksService()
    }
    
    /// Provides a shared `GamificationService` instance.
    @MainActor
    private func provideGamificationService() -> GamificationService {
        let notificationManager = provideNotificationManager()
        return GamificationService(modelContext: self.context, notificationManager: notificationManager)
    }
    
    /// Provides a shared `NotificationManager` instance.
    private func provideNotificationManager() -> NotificationManager {
        return NotificationManager()
    }
}
