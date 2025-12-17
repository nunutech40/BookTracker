//
//  ContentView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // TAB 1: HOME
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // TAB 2: LIBRARY (Shelf & Reading)
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            
            // TAB 3: PROFILE (NEW)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}
