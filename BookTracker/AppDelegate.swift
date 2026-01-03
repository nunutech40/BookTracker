//
//  AppDelegate.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Shared instance of NavigationCoordinator for deep linking
    let navigationCoordinator = NavigationCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Set the UNUserNotificationCenter delegate
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Called when a notification is delivered to a foreground app.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification as a banner and play a sound
        completionHandler([.banner, .sound])
    }
    
    // Called to let your app know which action a user has performed on a notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User interacted with notification: \(response.notification.request.identifier)")
        
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        switch categoryIdentifier {
        case "achievement_unlocked":
            let achievementID = userInfo["achievementID"] as? String
            navigationCoordinator.navigateToGamification(with: achievementID)
        case "daily_streak":
            navigationCoordinator.navigateToGamification()
        default:
            break
        }
        
        completionHandler()
    }
}
