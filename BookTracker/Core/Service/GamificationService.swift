//
//  GamificationService.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import SwiftData

protocol GamificationServiceProtocol {
    func loadAchievements() -> [GamificationAchievement]
    func checkAchievements(bookService: BookServiceProtocol) async -> [GamificationAchievement]
    func fetchAllUnlockedAchievements() throws -> [UnlockedAchievement]
}

final class GamificationService: GamificationServiceProtocol {
    
    private var allAchievements: [GamificationAchievement] = []
    private let modelContext: ModelContext
    private let notificationManager: NotificationManagerProtocol // New property
    
    init(modelContext: ModelContext, notificationManager: NotificationManagerProtocol) { // Updated initializer
        self.modelContext = modelContext
        self.notificationManager = notificationManager // Initialize new dependency
        self.allAchievements = loadAchievements()
    }

    /// Loads gamification achievements from the JSON file.
    func loadAchievements() -> [GamificationAchievement] {
        if let url = Bundle.main.url(forResource: "gamification_achievements", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let achievements = try decoder.decode([GamificationAchievement].self, from: data)
                print("✅ GamificationService: Loaded \(achievements.count) achievements from JSON.")
                return achievements
            } catch {
                print("❌ GamificationService: Error decoding achievements JSON: \(error)")
            }
        } else {
            print("❌ GamificationService: gamification_achievements.json not found in bundle.")
        }
        return []
    }

    /// Checks which achievements the user has unlocked based on their reading data.
    /// - Parameter bookService: The BookService to fetch user reading data.
    /// - Returns: An array of currently unlocked and persisted GamificationAchievement objects.
    @MainActor
    func checkAchievements(bookService: BookServiceProtocol) async -> [GamificationAchievement] {
        var currentlyUnlockedAchievements: [GamificationAchievement] = []
        
        // Fetch all necessary data from BookService once to optimize
        let allBooks = (try? await bookService.fetchAllBooks()) ?? []
        let allReadingSessions = (try? await bookService.fetchAllReadingSessions()) ?? []
        let heatmapData = bookService.fetchReadingHeatmap()
        
        // Fetch already unlocked achievements from persistence
        let persistedUnlockedAchievements = (try? self.fetchAllUnlockedAchievements()) ?? []
        let persistedAchievementIDs = Set(persistedUnlockedAchievements.map { $0.achievementID })
        
        let totalBooksFinished = allBooks.filter { $0.status == .finished }.count
        let totalBooksAdded = allBooks.count
        let totalPagesRead = allReadingSessions.reduce(0) { $0 + $1.pagesReadCount }
        let currentStreak = calculateCurrentStreak(heatmapData: heatmapData)

        for achievement in allAchievements {
            var isConditionMet = false
            switch achievement.conditionType {
            case .consecutiveDays:
                isConditionMet = currentStreak >= achievement.conditionValue
                
            case .pagesInSingleDay:
                let maxPagesInDay = heatmapData.values.max() ?? 0
                isConditionMet = maxPagesInDay >= achievement.conditionValue
                
            case .totalPagesRead:
                isConditionMet = totalPagesRead >= achievement.conditionValue
                
            case .readOnWeekend:
                let calendar = Calendar.current
                var foundWeekendRead = false
                let readingDaysByWeek = Dictionary(grouping: heatmapData.keys) { date in
                    calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                }
                
                for (_, daysInWeek) in readingDaysByWeek {
                    let hasSaturday = daysInWeek.contains { calendar.component(.weekday, from: $0) == 7 } // Saturday
                    let hasSunday = daysInWeek.contains { calendar.component(.weekday, from: $0) == 1 } // Sunday
                    if hasSaturday && hasSunday {
                        foundWeekendRead = true
                        break
                    }
                }
                isConditionMet = foundWeekendRead
                
            case .totalBooksFinished:
                isConditionMet = totalBooksFinished >= achievement.conditionValue
                
            case .daysReadInWeek:
                let calendar = Calendar.current
                var foundWeekWithEnoughReadingDays = false
                
                let readingDaysByWeek = Dictionary(grouping: heatmapData.keys) { date in
                    calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
                }
                
                for (_, daysInWeek) in readingDaysByWeek {
                    if daysInWeek.count >= achievement.conditionValue {
                        foundWeekWithEnoughReadingDays = true
                        break
                    }
                }
                isConditionMet = foundWeekWithEnoughReadingDays
                
            case .finishLargeBook:
                isConditionMet = allBooks.contains { $0.status == .finished && $0.totalPages >= achievement.conditionValue }
                
            case .totalBooksAdded:
                isConditionMet = totalBooksAdded >= achievement.conditionValue
                
            case .readBeforeTime:
                isConditionMet = allReadingSessions.contains { session in
                    let hour = Calendar.current.component(.hour, from: session.date)
                    return hour < achievement.conditionValue
                }
                
            case .readAfterTime:
                isConditionMet = allReadingSessions.contains { session in
                    let hour = Calendar.current.component(.hour, from: session.date)
                    return hour >= achievement.conditionValue
                }
            }
            
            if isConditionMet {
                // If condition is met and not yet persisted, save it
                if !persistedAchievementIDs.contains(achievement.id) {
                    let newUnlockedAchievement = UnlockedAchievement(achievementID: achievement.id, unlockedDate: Date())
                    modelContext.insert(newUnlockedAchievement)
                    do {
                        try modelContext.save()
                        print("🎉 GamificationService: NEW achievement unlocked and saved: \(achievement.title)")
                        // Trigger notification for newly unlocked achievement
                        notificationManager.scheduleAchievementNotification(title: achievement.title, message: achievement.message)
                    } catch {
                        print("❌ GamificationService: Failed to save new unlocked achievement: \(error)")
                    }
                }
                currentlyUnlockedAchievements.append(achievement)
            }
        }
        
        return currentlyUnlockedAchievements
    }
    
    // MARK: - Persistence Fetcher
    func fetchAllUnlockedAchievements() throws -> [UnlockedAchievement] {
        let descriptor = FetchDescriptor<UnlockedAchievement>()
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Helper Functions
    // Aligned with HomeViewModel's streak calculation
    private func calculateCurrentStreak(heatmapData: [Date: Int]) -> Int {
        let readDates = heatmapData.keys.sorted(by: >)
        guard !readDates.isEmpty else {
            return 0
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let lastReadDate = calendar.startOfDay(for: readDates[0])
        if lastReadDate != today && lastReadDate != yesterday {
            return 0
        }
        
        var streak = 0
        var currentDateToCheck = lastReadDate
        let dateSet = Set(readDates.map { calendar.startOfDay(for: $0) })
        
        while dateSet.contains(currentDateToCheck) {
            streak += 1
            if let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDateToCheck) {
                currentDateToCheck = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
}
