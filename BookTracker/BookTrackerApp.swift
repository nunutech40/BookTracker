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
    
    // Using an AppDelegateAdaptor to hook into the UIApplicationDelegate lifecycle
    // and manage UNUserNotificationCenterDelegate for foreground notifications.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // 1. Init Container (Tetap sama)
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Book.self,
            ReadingSession.self,
            UnlockedAchievement.self // Add UnlockedAchievement to the schema
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Create the ViewModel instance here
    @State private var homeViewModel: HomeViewModel
    
    init() {
        //  Lakukan Inject Container sekali di awal
        let injection = Injection.shared
        injection.setup(container: sharedModelContainer)
        
        // Create the ViewModel
        let vm = injection.provideHomeViewModel()
        _homeViewModel = State(initialValue: vm)
        
        // Start loading data in the background immediately
        Task {
            await vm.refreshData()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                homeViewModel: homeViewModel,
                profileViewModel: Injection.shared.provideProfileViewModel(),
                navigationCoordinator: appDelegate.navigationCoordinator // Pass the coordinator
            )
        }
        // Jangan lupa modifier ini tetap wajib ada biar SwiftUI environment jalan
        .modelContainer(sharedModelContainer)
    }
}
