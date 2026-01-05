//
//  PermissionDeniedView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 03/01/26.
//

import SwiftUI

struct PermissionDeniedView: View {
    let permissionType: PermissionManager.PermissionType
    
    var title: String {
        switch permissionType {
        case .camera:
            return NSLocalizedString("Camera Access Denied", comment: "")
        case .photoLibrary:
            return NSLocalizedString("Photo Library Access Denied", comment: "")
        }
    }
    
    var message: String {
        switch permissionType {
        case .camera:
            return NSLocalizedString("To use this feature, please enable camera access in Settings.", comment: "")
        case .photoLibrary:
            return NSLocalizedString("To use this feature, please enable photo library access in Settings.", comment: "")
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(NSLocalizedString("Open Settings", comment: "")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
