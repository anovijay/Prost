//
//  LevelPassagesView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelPassagesView: View {
    let progress: UserProgress
    
    @EnvironmentObject private var appState: AppState
    
    private var passageCompletionInfo: PassageCompletionInfo? {
        let history = appState.getCompletionHistory(for: ReadingPassage.sampleBerlinDay.id)
        guard !history.isEmpty else { return nil }
        
        let bestScore = history.map { $0.score }.max() ?? 0.0
        return PassageCompletionInfo(
            attemptCount: history.count,
            bestScore: bestScore
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Sample passage for this level
                NavigationLink {
                    ReadingPassageView(passage: .sampleBerlinDay)
                } label: {
                    PassageCardView(
                        title: "Ein Tag in Berlin",
                        questionCount: 3,
                        completionInfo: passageCompletionInfo
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle(progress.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
    }
}

// MARK: - Supporting Types

struct PassageCompletionInfo {
    let attemptCount: Int
    let bestScore: Double
    
    var bestScorePercentage: Int {
        Int(bestScore * 100)
    }
}

// MARK: - Passage Card Component

struct PassageCardView: View {
    let title: String
    let questionCount: Int
    let completionInfo: PassageCompletionInfo?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    // Question count
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("\(questionCount) questions")
                            .font(ProstTheme.Typography.caption)
                    }
                    .foregroundStyle(.secondary)
                    
                    // Attempt count (if completed)
                    if let info = completionInfo {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                            Text("\(info.attemptCount) attempt\(info.attemptCount == 1 ? "" : "s")")
                                .font(ProstTheme.Typography.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Completion status with best score
                if let info = completionInfo {
                    HStack(spacing: 4) {
                        if info.bestScore == 1.0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                        Text("\(info.bestScorePercentage)%")
                            .font(ProstTheme.Typography.body.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.body)
                        .foregroundStyle(.secondary.opacity(0.3))
                }
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .prostCard()
    }
}
