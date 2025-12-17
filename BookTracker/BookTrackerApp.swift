//
//  BookTrackerApp.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI
import SwiftData

@main
struct BookTrackerApp: App {
    
    // 1. Init Container (Tetap sama)
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            ReadingSession.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // 2. Custom Init untuk Setup Injection
    init() {
        //  Lakukan Inject Container sekali di awal
        Injection.shared.setup(container: sharedModelContainer)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                homeViewModel: Injection.shared.provideHomeViewModel(),
                profileViewModel: Injection.shared.provideProfileViewModel()
            )
        }
        // Jangan lupa modifier ini tetap wajib ada biar SwiftUI environment jalan
        .modelContainer(sharedModelContainer)
    }
}
