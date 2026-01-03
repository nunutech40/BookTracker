//
//  PermissionManager.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 03/01/26.
//

import Foundation
import AVFoundation
import Photos

@MainActor
class PermissionManager: ObservableObject {
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
    
    @Published var cameraStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    func requestPermission(for type: PermissionType, completion: @escaping (Bool) -> Void) {
        switch type {
        case .camera:
            requestCameraPermission(completion: completion)
        case .photoLibrary:
            requestPhotoLibraryPermission(completion: completion)
        }
    }
    
    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
                completion(granted)
            }
        }
    }
    
    private func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.photoLibraryStatus = status
                completion(status == .authorized || status == .limited)
            }
        }
    }
}
