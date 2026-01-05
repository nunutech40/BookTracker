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
            Section(NSLocalizedString("Unlocked Achievements", comment: "")) {
                if viewModel.unlockedAchievements.isEmpty {
                    Text(NSLocalizedString("No achievements unlocked yet. Keep reading!", comment: ""))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.unlockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, isUnlocked: true)
                    }
                }
            }
            
            Section(NSLocalizedString("Locked Achievements", comment: "")) {
                if viewModel.lockedAchievements.isEmpty {
                    Text(NSLocalizedString("All achievements unlocked! You're a legend!", comment: ""))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.lockedAchievements) { achievement in
                        AchievementRow(achievement: achievement, isUnlocked: false)
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("Achievements", comment: ""))
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
