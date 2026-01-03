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
    
    var body: some View {
        TabView {
            // TAB 1: HOME
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label(String(localized: "Home"), systemImage: "house.fill")
                }
            
            // TAB 2: LIBRARY (Shelf & Reading)
            LibraryView()
                .tabItem {
                    Label(String(localized: "Library"), systemImage: "books.vertical.fill")
                }
            
            // TAB 3: PROFILE (NEW)
            ProfileView(viewModel: profileViewModel)
                .tabItem {
                    Label(String(localized: "Profile"), systemImage: "person.crop.circle")
                }
        }
    }
}
