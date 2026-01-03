//
//  SupportDeveloperView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 03/01/26.
//

import SwiftUI

struct SupportDeveloperView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
                    .padding(.top, 40)
                
                Text(NSLocalizedString("Support the Developer", comment: ""))
                    .font(.title)
                    .bold()
                
                Text(NSLocalizedString("If you enjoy BookTracker, please consider supporting its development. Your contribution helps keep this app updated and free from ads, and allows me to dedicate more time to creating new features.", comment: ""))
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    Link(destination: URL(string: "https://buymeacoffee.com/yourprofile")!) {
                        Label(NSLocalizedString("Buy Me a Coffee", comment: ""), systemImage: "mug.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow.opacity(0.8))
                            .foregroundColor(.black)
                            .cornerRadius(10)
                    }
                    
                    Link(destination: URL(string: "https://ko-fi.com/yourprofile")!) {
                        Label(NSLocalizedString("Support on Ko-fi", comment: ""), systemImage: "cup.and.saucer.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Link(destination: URL(string: "https://paypal.me/yourprofile")!) {
                        Label(NSLocalizedString("Donate via PayPal", comment: ""), systemImage: "dollarsign.circle.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("Support", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}
