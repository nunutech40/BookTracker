//
//  NavigationCoordinator.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import SwiftUI // For @Published and ObservableObject, or @Observable

// This class will manage navigation state for deep linking from notifications
@Observable
class NavigationCoordinator {
    var showGamificationView: Bool = false
    var selectedAchievementID: String? = nil
    
    // Call this method to trigger navigation
    func navigateToGamification(with achievementID: String? = nil) {
        self.selectedAchievementID = achievementID
        self.showGamificationView = true
    }
    
    // Call this method when the view is dismissed
    func dismissGamification() {
        self.showGamificationView = false
        self.selectedAchievementID = nil
    }
}
