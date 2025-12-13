//
//  LevelProgressCard.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelProgressCard: View {
    let levelProgress: LevelProgress
    
    var body: some View {
        HStack(spacing: 16) {
            // Level badge
            Text(levelProgress.level)
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
                Text("\(levelProgress.passagesCompleted) passages completed")
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
                
                if levelProgress.passagesCompleted > 0 {
                    Text("Overall score: \(Int(levelProgress.overallScore * 100))%")
                        .font(ProstTheme.Typography.caption)
                        .foregroundStyle(.secondary)
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

