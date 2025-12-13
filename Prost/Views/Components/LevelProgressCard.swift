//
//  LevelProgressCard.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelProgressCard: View {
    let progress: UserProgress
    @Binding var isExpanded: Bool
    let onNavigate: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if progress.completedCount > 0 {
                            Text("\(progress.completedCount) passage\(progress.completedCount == 1 ? "" : "s") • \(progress.bestScorePercentage)%")
                                .font(ProstTheme.Typography.body.weight(.medium))
                                .foregroundStyle(.primary)
                        } else {
                            Text(progress.level)
                                .font(ProstTheme.Typography.body.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        
                        Text(progress.completedCount > 0 ? "In Progress" : "Not Started")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Expand/collapse chevron
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    if progress.completedCount > 0 {
                        // Stats
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Current Score:")
                                    .font(ProstTheme.Typography.body)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(progress.bestScorePercentage)%")
                                    .font(ProstTheme.Typography.body.weight(.bold))
                                    .foregroundStyle(.primary)
                            }
                            
                            HStack {
                                Text("Completed:")
                                    .font(ProstTheme.Typography.body)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(progress.completedCount) passage\(progress.completedCount == 1 ? "" : "s")")
                                    .font(ProstTheme.Typography.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, 16)
                    } else {
                        // Not started message
                        Text("Start practicing to track your progress")
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                    }
                    
                    // Navigate button
                    Button {
                        onNavigate()
                    } label: {
                        HStack {
                            Text("Continue Practice")
                                .font(ProstTheme.Typography.body.weight(.medium))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.body)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .prostCard()
    }
}
