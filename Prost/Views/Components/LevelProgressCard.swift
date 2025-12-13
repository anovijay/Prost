//
//  LevelProgressCard.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelProgressCard: View {
    let progress: UserProgress
    
    var body: some View {
        HStack(spacing: 16) {
            // Level badge
            Text(progress.level)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.accentColor.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.accentColor.opacity(0.3), lineWidth: 1.5)
                        )
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(progress.completedCount) passages completed")
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
                
                if progress.completedCount > 0 {
                    // Show both latest and best scores (Q1 requirement)
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Text("Latest:")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            Text("\(progress.latestScorePercentage)%")
                                .font(ProstTheme.Typography.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        HStack(spacing: 4) {
                            Text("Best:")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            Text("\(progress.bestScorePercentage)%")
                                .font(ProstTheme.Typography.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                } else {
                    Text("Not started")
                        .font(ProstTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .prostCard()
    }
}

