//
//  NotificationManager.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation
import UserNotifications

protocol NotificationManagerProtocol {
    func requestAuthorization() async -> Bool // Make async and return Bool
    func scheduleAchievementNotification(title: String, message: String, achievementID: String) // Add achievementID
    func scheduleDailyStreakNotification(currentStreak: Int)
}

final class NotificationManager: NotificationManagerProtocol {
    
    init() {
        // No longer request authorization in init directly, it will be done on demand
    }
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                print("✅ NotificationManager: Notification authorization granted.")
            } else {
                print("❌ NotificationManager: Notification authorization denied.")
            }
            return granted
        } catch {
            print("❌ NotificationManager: Notification authorization request failed with error: \(error.localizedDescription)")
            return false
        }
    }
    
    private func getNotificationStatus() async -> UNNotificationSetting {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.alertSetting
    }
    
    private func scheduleNotification(content: UNMutableNotificationContent, identifier: String) async {
        let status = await getNotificationStatus()
        guard status == .enabled else {
            print("⚠️ NotificationManager: Notifications not enabled. Cannot schedule \(identifier).")
            return
        }
        
        // Use an immediate trigger for these types of notifications
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ NotificationManager: Notification scheduled: \(identifier)")
        } catch {
            print("❌ NotificationManager: Error scheduling notification \(identifier): \(error.localizedDescription)")
        }
    }
    
    func scheduleAchievementNotification(title: String, message: String, achievementID: String) { // Updated signature
        let content = UNMutableNotificationContent()
        content.title = "Achievement Unlocked!"
        content.subtitle = title
        content.body = message
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "achievement_unlocked" // Add category identifier
        content.userInfo = ["achievementID": achievementID] // Add userInfo
        
        Task { // Ensure this is called in an async context
            await scheduleNotification(content: content, identifier: UUID().uuidString)
        }
    }
    
    func scheduleDailyStreakNotification(currentStreak: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Streak Update!"
        content.body = "You're on a \(currentStreak)-day streak! Keep it up!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "daily_streak" // Add category identifier
        
        Task { // Ensure this is called in an async context
            await scheduleNotification(content: content, identifier: "daily_streak_notification")
        }
    }
}
