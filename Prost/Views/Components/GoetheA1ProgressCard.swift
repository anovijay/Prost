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
    @Binding var isExpanded: Bool
    let onNavigate: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible) - tappable to expand/collapse
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            } label: {
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
                            .font(ProstTheme.Typography.body.weight(.medium))
                            .foregroundStyle(.primary)
                        
                        if progress.isStarted {
                            HStack(spacing: 8) {
                                Text("Best: \(progress.bestScorePercentage)%")
                                    .font(ProstTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                                if progress.isPassed {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                        } else {
                            Text("Not started")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
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
                    
                    if progress.isStarted {
                        // Scores
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                StatItem(label: "Latest", value: "\(progress.latestScorePercentage)%")
                                StatItem(label: "Best", value: "\(progress.bestScorePercentage)%")
                                StatItem(label: "Average", value: "\(progress.averageScorePercentage)%")
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 3-Part breakdown
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Parts Performance")
                                .font(ProstTheme.Typography.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 12) {
                                PartScoreChip(
                                    partNumber: 1,
                                    title: "Informal",
                                    score: progress.part1ScorePercentage
                                )
                                
                                PartScoreChip(
                                    partNumber: 2,
                                    title: "Situations",
                                    score: progress.part2ScorePercentage
                                )
                                
                                PartScoreChip(
                                    partNumber: 3,
                                    title: "Signs",
                                    score: progress.part3ScorePercentage
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // Metadata
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
                        }
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                    } else {
                        // Exam structure overview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exam Structure (15 questions, 25 min)")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 12) {
                                ExamPartIndicator(
                                    number: 1,
                                    title: "Informal Texts",
                                    subtitle: "5 True/False"
                                )
                                
                                ExamPartIndicator(
                                    number: 2,
                                    title: "Situations",
                                    subtitle: "5 A/B Choice"
                                )
                                
                                ExamPartIndicator(
                                    number: 3,
                                    title: "Signs",
                                    subtitle: "5 True/False"
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Navigate button
                    Button {
                        onNavigate()
                    } label: {
                        HStack {
                            Text(progress.isStarted ? "View Exams" : "Start Practicing")
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
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Preview

#Preview("Started Progress") {
    VStack(spacing: 16) {
        GoetheA1ProgressCard(
            progress: .sampleProgress,
            isExpanded: .constant(true),
            onNavigate: {}
        )
    }
    .padding()
    .prostBackground()
}

#Preview("Not Started") {
    VStack(spacing: 16) {
        GoetheA1ProgressCard(
            progress: .notStartedProgress,
            isExpanded: .constant(true),
            onNavigate: {}
        )
    }
    .padding()
    .prostBackground()
}
