//
//  AboutView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "book.pages.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .padding(.top, 40)
                
                VStack(spacing: 8) {
                    Text(String(format: NSLocalizedString("BookTracker %@", comment: ""), appVersion))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(NSLocalizedString("Created by Nunu Nugraha", comment: ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(10)
                .shadow(radius: 2)
                
                Text(NSLocalizedString("A simple app to track your daily book reading progress. Made with love using SwiftUI & SwiftData.", comment: ""))
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal)

                Text(NSLocalizedString("about.developer.story", comment: ""))
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .padding(.horizontal)
                
                NavigationLink {
                    SupportDeveloperView()
                } label: {
                    Text(NSLocalizedString("Support Developer (Donate)", comment: ""))
                        .font(.headline)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(String(localized: "About"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
