//
//  GamificationView.swift
//  BookTracker
//
//  Created by Nunu Nugraha on 07/12/25.
//

import SwiftUI

struct GamificationView: View {
    @State var viewModel: GamificationViewModel
    
    var body: some View {
        List {
            Section("Unlocked Achievements") {
                if viewModel.unlockedAchievements.isEmpty {
                    Text("No achievements unlocked yet. Keep reading!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.unlockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, isUnlocked: true)
                    }
                }
            }
            
            Section("Locked Achievements") {
                if viewModel.lockedAchievements.isEmpty {
                    Text("All achievements unlocked! You're a legend!")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.lockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, isUnlocked: false)
                    }
                }
            }
        }
        .navigationTitle("Achievements")
        .onAppear {
            viewModel.loadAndCheckAchievements()
        }
    }
}

struct AchievementRow: View {
    let achievement: GamificationAchievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: achievement.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(isUnlocked ? .yellow : .gray) // Changed .accentColor to .yellow
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(isUnlocked ? .secondary : .tertiary)
            }
            Spacer()
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
}
