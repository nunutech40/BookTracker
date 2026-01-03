//
//  GamificationViewModel.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import SwiftUI // For @MainActor

@Observable
final class GamificationViewModel {
    
    private var gamificationService: GamificationServiceProtocol
    private var bookService: BookServiceProtocol // Needed to pass to gamificationService.checkAchievements
    
    var allAchievements: [GamificationAchievement] = []
    var unlockedAchievements: [GamificationAchievement] = []
    var lockedAchievements: [GamificationAchievement] = []
    
    init(gamificationService: GamificationServiceProtocol, bookService: BookServiceProtocol) {
        self.gamificationService = gamificationService
        self.bookService = bookService
        
        // Removed: loadAndCheckAchievements() from init
    }
    
    @MainActor
    func loadAndCheckAchievements() {
        allAchievements = gamificationService.loadAchievements()
        Task {
            // This call to checkAchievements will ensure any newly met achievements are persisted.
            // However, for displaying ALL previously unlocked achievements, we need to fetch them from persistence.
            _ = await gamificationService.checkAchievements(bookService: bookService) // Run to persist any new ones

            do {
                let persistedUnlocked = try gamificationService.fetchAllUnlockedAchievements()
                let persistedAchievementIDs = Set(persistedUnlocked.map { $0.achievementID })

                self.unlockedAchievements = allAchievements.filter { persistedAchievementIDs.contains($0.id) }
                self.lockedAchievements = allAchievements.filter { !persistedAchievementIDs.contains($0.id) }
            } catch {
                print("Error fetching persisted unlocked achievements: \(error)")
                self.unlockedAchievements = []
                self.lockedAchievements = allAchievements
            }
        }
    }
}
