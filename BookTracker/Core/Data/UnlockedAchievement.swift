//
//  UnlockedAchievement.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import SwiftData

@Model
final class UnlockedAchievement {
    let id: UUID // Internal ID for SwiftData
    let achievementID: String // Corresponds to GamificationAchievement.id
    let unlockedDate: Date
    
    init(achievementID: String, unlockedDate: Date) {
        self.id = UUID()
        self.achievementID = achievementID
        self.unlockedDate = unlockedDate
    }
}
