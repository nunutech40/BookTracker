# TODO: MVP Refinement & Features - BookTracker App

This document outlines the remaining tasks to complete the MVP, focusing on code documentation, reading targets, local notifications, and gamification copywriting.

## 1. Documentation & Code Quality
- [x] **BookEditor Validation Docs**:
    - Add comprehensive comments/documentation in `BookEditorViewModel`.
    - Explain the "Dirty State" logic (`hasInteracted`) and `ValidationState` computed properties.
    - Explain the Regex logic used for sanitizing `totalPages` input.

## 2. Feature: Reading Targets (Goals) - Hybrid Approach

**Concept**: Implement the reading goals feature with settings in the Profile tab and an entry point/summary on the Home tab for better visibility and engagement.

- [ ] **A. Entry Point on Home Tab**:
    - Create a new component `ReadingGoalSummaryView`.
    - **Scenario 1 (No Goal)**: Display a card with a call-to-action, e.g., "Set Your Weekly Reading Goal". Tapping it should navigate to the `ReadingGoalView` in the Profile tab.
    - **Scenario 2 (Goal is Set)**: Display a summary of the current goal and progress (e.g., "This week's goal: 2 books. You've read 1."). Tapping it navigates to the detailed `ReadingGoalView`.

- [ ] **B. Main Settings in Profile Tab**:
    - Create `ReadingGoalView` inside the Profile feature (`Features/Profile/View`).
    - This view will contain the UI for setting and managing goals.
    - **Target UI Implementation**:
        - Allow users to set targets based on:
            - **Frequency**: Daily, Weekly, Yearly.
            - **Metric**:
                - *Pages* (Only available for 'Daily' frequency).
                - *Books* (Available for Daily, Weekly, Yearly).

- [ ] **C. Target Logic & Data**:
    - Implement logic to break down long-term targets into daily chunks:
        - *Formula*: If Target is "50 Books/Year", calculate: `(Target - FinishedBooks) / DaysRemaining`.
    - Store these preferences using `@AppStorage` or `UserDefaults`.

## 3. Feature: Local Notifications (Reminder System)
Implement `UserNotifications` to remind users to read based on their targets.

- [ ] **Notification Setup**:
    - Request notification permissions on app launch or when setting a target.
    - Set default reminder time: **20:00 (8 PM)** (Optimal time for post-work reading).
- [ ] **Trigger Logic**:
    - **Scenario A (Has Target)**:
        - Check `ReadingSession` for the current day.
        - If `progress < dailyTarget`, schedule/trigger the notification.
        - Message content: Reminder + progress status (e.g., "You are 10 pages away from your goal!").
    - **Scenario B (No Target)**:
        - Schedule daily notification at the default time.
        - Message content: Random motivational quote from the "General" category.

## 4. Gamification & Copywriting (Content)
Create a `MotivationService` or helper to supply dynamic text.

- [ ] **Copywriting Database (The "Soul")**:
    - Create a JSON/Struct collection of quotes categorized by:
        - *General/No Target*: "Reading is to the mind what exercise is to the body."
        - *Daily Grind*: Reminders for hourly/daily consistency.
        - *Achievement Unlocked*: Special messages when hitting targets.
- [ ] **Persona Categories (Gamification)**:
    - Logic: Compare user velocity to famous figures.
    - **Levels**:
        - *The Visionary (High Velocity)*: "You read like **Elon Musk** / **Theodore Roosevelt** (1 book/day)!"
        - *The Strategist (Medium Velocity)*: "You're on **Bill Gates'** pace (1 book/week)."
        - *The Sage (Steady)*: "Consistency like **Warren Buffett**."
- [ ] **Randomizer Logic**:
    - Ensure the user doesn't see the same push notification message twice in a row.

---

## 5. Technical Context (For AI Reference)
- **Stack**: SwiftUI, SwiftData, Observation Framework.
- **Core Data**: `Book` model (SwiftData), `ReadingSession` (history).
- **Service**: `BookService` handles all data manipulation.
- **Goal**: Keep the MVP lightweight. No social features yet.