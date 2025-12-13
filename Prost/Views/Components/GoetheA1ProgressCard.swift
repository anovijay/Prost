//
//  GoetheA1ProgressCard.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

/// Special progress card for Goethe A1 exam format showing 3-part structure
struct GoetheA1ProgressCard: View {
    let progress: GoetheA1UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with level badge and format indicator
            HStack(spacing: 16) {
                // Level badge
                Text("A1")
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
                    Text("Goethe-Zertifikat A1")
                        .font(ProstTheme.Typography.title)
                        .foregroundStyle(.primary)
                    
                    if progress.isStarted {
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Text("Latest:")
                                    .font(ProstTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(progress.latestScorePercentage)%")
                                    .font(ProstTheme.Typography.caption.weight(.semibold))
                                    .foregroundStyle(progress.isPassed ? .green : .orange)
                            }
                            HStack(spacing: 4) {
                                Text("Best:")
                                    .font(ProstTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(progress.bestScorePercentage)%")
                                    .font(ProstTheme.Typography.caption.weight(.semibold))
                                    .foregroundStyle(progress.isPassed ? .green : .orange)
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
            
            // 3-Part structure indicator (only if started)
            if progress.isStarted {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Parts Performance")
                        .font(ProstTheme.Typography.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        // Part 1
                        PartScoreChip(
                            partNumber: 1,
                            title: "Informal Texts",
                            score: progress.part1ScorePercentage
                        )
                        
                        // Part 2
                        PartScoreChip(
                            partNumber: 2,
                            title: "Situations",
                            score: progress.part2ScorePercentage
                        )
                        
                        // Part 3
                        PartScoreChip(
                            partNumber: 3,
                            title: "Signs",
                            score: progress.part3ScorePercentage
                        )
                    }
                }
            } else {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exam Structure")
                        .font(ProstTheme.Typography.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        ExamPartIndicator(
                            number: 1,
                            title: "Informal Texts",
                            subtitle: "5 questions"
                        )
                        
                        ExamPartIndicator(
                            number: 2,
                            title: "Situations",
                            subtitle: "5 questions"
                        )
                        
                        ExamPartIndicator(
                            number: 3,
                            title: "Signs",
                            subtitle: "5 questions"
                        )
                    }
                }
            }
            
            // Metadata row
            if progress.isStarted {
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                        Text("\(progress.completedCount) exam\(progress.completedCount == 1 ? "" : "s")")
                            .font(ProstTheme.Typography.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                        Text("\(progress.totalAttempts) attempt\(progress.totalAttempts == 1 ? "" : "s")")
                            .font(ProstTheme.Typography.caption)
                    }
                    
                    if progress.isPassed {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text("Passed")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.green)
                        }
                    }
                    
                    Spacer()
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .prostCard()
    }
}

// MARK: - Supporting Components

/// Small chip showing part number and score
struct PartScoreChip: View {
    let partNumber: Int
    let title: String
    let score: Int
    
    var scoreColor: Color {
        if score >= 80 { return .green }
        if score >= 60 { return .orange }
        return .red
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Part \(partNumber)")
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(.secondary)
            
            Text("\(score)%")
                .font(.system(.body, design: .rounded).weight(.bold))
                .foregroundStyle(scoreColor)
            
            Text(title)
                .font(.system(.caption2))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

/// Indicator for exam part (when not started)
struct ExamPartIndicator: View {
    let number: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(number)")
                .font(.system(.body, design: .rounded).weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.12))
                )
            
            Text(title)
                .font(.system(.caption2))
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Text(subtitle)
                .font(.system(.caption2))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview

#Preview("Started Progress") {
    VStack(spacing: 16) {
        GoetheA1ProgressCard(progress: .sampleProgress)
    }
    .padding()
    .prostBackground()
}

#Preview("Not Started") {
    VStack(spacing: 16) {
        GoetheA1ProgressCard(progress: .notStartedProgress)
    }
    .padding()
    .prostBackground()
}

