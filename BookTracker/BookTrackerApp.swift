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
    
    // Definisi Container untuk Schema Book & ReadingSession
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

    var body: some Scene {
        WindowGroup {
            ContentView(homeViewModel: Injection.shared.provideHomeViewModel(modelContext: sharedModelContainer.mainContext))
        }
        // Inject ke sini
        .modelContainer(sharedModelContainer)
    }
}
