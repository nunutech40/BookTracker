//
//  AboutView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding(.top, 40)
                
                Text("BookTracker v1.0")
                    .font(.title)
                    .bold()
                
                Text("Created by Nunu Nugraha")
                    .foregroundStyle(.secondary)
                
                Divider()
                
                Text("Aplikasi simpel untuk mencatat progres baca buku harianmu. Dibuat dengan cinta menggunakan SwiftUI & SwiftData.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
