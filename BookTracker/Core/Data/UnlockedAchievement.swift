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
    var id: UUID // Internal ID for SwiftData
    var achievementID: String // Corresponds to GamificationAchievement.id
    var unlockedDate: Date
    
    init(achievementID: String, unlockedDate: Date) {
        self.id = UUID()
        self.achievementID = achievementID
        self.unlockedDate = unlockedDate
    }
}
