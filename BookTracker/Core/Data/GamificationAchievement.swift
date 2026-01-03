//
//  GamificationAchievement.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import Foundation

struct GamificationAchievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let message: String
    let icon: String // SF Symbol name
    let conditionType: ConditionType
    let conditionValue: Int
    
    enum ConditionType: String, Codable {
        case consecutiveDays = "consecutive_days"
        case pagesInSingleDay = "pages_in_single_day"
        case totalPagesRead = "total_pages_read"
        case readOnWeekend = "read_on_weekend"
        case totalBooksFinished = "total_books_finished"
        case daysReadInWeek = "days_read_in_week"
        case finishLargeBook = "finish_large_book"
        case totalBooksAdded = "total_books_added"
        case readBeforeTime = "read_before_time"
        case readAfterTime = "read_after_time"
    }
}
