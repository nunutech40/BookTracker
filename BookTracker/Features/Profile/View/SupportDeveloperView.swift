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
            VStack(spacing: 24) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                    .shadow(radius: 10)
                    .padding(.top, 40)
                
                Text(NSLocalizedString("Dukung Developer Indie", comment: ""))
                    .font(.largeTitle)
                    .bold()
                
                Text(NSLocalizedString("Hai, saya Nunu, developer tunggal di balik BookTracker. Aplikasi ini saya buat dari passion untuk membaca dan teknologi. Dukungan Anda sangat berarti untuk menjaga aplikasi ini tetap gratis, bebas iklan, dan terus berkembang dengan fitur-fitur baru. Setiap traktiran kopi dari Anda memberi saya energi dan motivasi untuk terus berkarya!", comment: ""))
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    Link(destination: URL(string: "https://saweria.co/nunugraha17")!) {
                        Label(NSLocalizedString("Traktir di Saweria", comment: ""), systemImage: "sparkles")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .orange.opacity(0.4), radius: 5, y: 2)
                    }
                    
                    Link(destination: URL(string: "https://www.buymeacoffee.com/nunutech401")!) {
                        Label(NSLocalizedString("Traktir di Buy Me a Coffee", comment: ""), systemImage: "mug.fill")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .shadow(color: .yellow.opacity(0.4), radius: 5, y: 2)
                    }
                }
                .padding()
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(NSLocalizedString("Dukung Developer", comment: ""))
        .navigationBarTitleDisplayMode(.inline)
    }
}
