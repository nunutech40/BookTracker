//
//  ContentView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct ContentView: View {
    
    @State var homeViewModel: HomeViewModel
    @State var profileViewModel: ProfileViewModel
    @State var navigationCoordinator: NavigationCoordinator // New
    
    @Environment(\.scenePhase) private var scenePhase // New
    
    // Add a State for the selected tab to ensure correct tab is active for navigation
    @State private var selectedTab: Tab = .home // New

    enum Tab: Hashable { // New
        case home
        case library
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) { // Updated TabView
            // TAB 1: HOME
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label(String(localized: "Home"), systemImage: "house.fill")
                }
                .tag(Tab.home) // Add tag
            
            // TAB 2: LIBRARY (Shelf & Reading)
            LibraryView()
                .tabItem {
                    Label(String(localized: "Library"), systemImage: "books.vertical.fill")
                }
                .tag(Tab.library) // Add tag
            
            // TAB 3: PROFILE (NEW)
            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Label(String(localized: "Profile"), systemImage: "person.crop.circle")
                }
                .tag(Tab.profile) // Add tag
        }
        .sheet(isPresented: $navigationCoordinator.showGamificationView) { // New sheet for deep linking
            // Present GamificationView as a sheet
            // We need to provide the viewModel here, or handle specific achievement selection
            GamificationView(viewModel: Injection.shared.provideGamificationViewModel())
                .onDisappear {
                    navigationCoordinator.dismissGamification() // Reset coordinator state when sheet is dismissed
                }
        }
        .onChange(of: navigationCoordinator.showGamificationView) { show in // New onChange for programmatic navigation
            if show {
                // If we navigate to GamificationView, ensure Profile tab is selected first
                selectedTab = .profile
            }
        }
    }
}
