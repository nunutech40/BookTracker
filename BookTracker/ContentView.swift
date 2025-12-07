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
            // Tab 1: Dashboard
            HomeView()
                .tabItem {
                    Label("Reading Now", systemImage: "book.fill")
                }
            
            // Tab 2: Library (NEW)
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
