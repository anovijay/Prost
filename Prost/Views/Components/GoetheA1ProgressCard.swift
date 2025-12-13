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
    
    // Readiness status
    private var readinessStatus: (text: String, color: Color, icon: String) {
        let score = progress.bestScorePercentage
        if score >= 80 {
            return ("Ready ✓", .green, "checkmark.seal.fill")
        } else if score >= 60 {
            return ("Almost Ready", .orange, "exclamationmark.triangle.fill")
        } else if progress.isStarted {
            return ("Keep Practicing", .orange, "arrow.clockwise")
        } else {
            return ("Not Started", .secondary, "")
        }
    }
    
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
                        if progress.isStarted {
                            Text("Current: \(progress.bestScorePercentage)%")
                                .font(ProstTheme.Typography.body.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            Text(readinessStatus.text)
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(readinessStatus.color)
                        } else {
                            Text("A1")
                                .font(ProstTheme.Typography.body.weight(.medium))
                                .foregroundStyle(.primary)
                            
                            Text("Not Started")
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
                        // Part scores with status icons
                        VStack(alignment: .leading, spacing: 8) {
                            PartScoreRow(
                                partNumber: 1,
                                title: "Part 1",
                                score: progress.part1ScorePercentage
                            )
                            
                            PartScoreRow(
                                partNumber: 2,
                                title: "Part 2",
                                score: progress.part2ScorePercentage
                            )
                            
                            PartScoreRow(
                                partNumber: 3,
                                title: "Part 3",
                                score: progress.part3ScorePercentage
                            )
                        }
                        .padding(.horizontal, 16)
                    } else {
                        // Not started: Show exam structure
                        VStack(alignment: .leading, spacing: 8) {
                            Text("3 Parts • 15 Questions • 25 min")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                ExamPartDescription(
                                    number: 1,
                                    title: "Informal Texts",
                                    description: "5 True/False questions"
                                )
                                
                                ExamPartDescription(
                                    number: 2,
                                    title: "Situations",
                                    description: "5 A/B Choices"
                                )
                                
                                ExamPartDescription(
                                    number: 3,
                                    title: "Signs & Notices",
                                    description: "5 True/False questions"
                                )
                            }
                            
                            Text("Pass threshold: 60%")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Action button
                    Button {
                        onNavigate()
                    } label: {
                        HStack {
                            Text(progress.isStarted ? "Continue Practice" : "Start First Exam")
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

/// Row showing part score with status icon
struct PartScoreRow: View {
    let partNumber: Int
    let title: String
    let score: Int
    
    private var statusIcon: (name: String, color: Color) {
        if score >= 80 {
            return ("checkmark.circle.fill", .green)
        } else if score >= 60 {
            return ("exclamationmark.triangle.fill", .orange)
        } else {
            return ("exclamationmark.triangle.fill", .red)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(ProstTheme.Typography.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text("\(score)%")
                .font(ProstTheme.Typography.body.weight(.semibold))
                .foregroundStyle(statusIcon.color)
            
            Image(systemName: statusIcon.name)
                .font(.body)
                .foregroundStyle(statusIcon.color)
        }
    }
}

/// Description of exam part (not started state)
struct ExamPartDescription: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(number).")
                .font(ProstTheme.Typography.body.weight(.bold))
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
                Text(description)
                    .font(ProstTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview("Started - Ready") {
    VStack(spacing: 16) {
        GoetheA1ProgressCard(
            progress: GoetheA1UserProgress(
                userId: User.sampleUser.id,
                completedExamIds: [UUID()],
                totalAttempts: 2,
                bestScore: 0.85,
                isPassed: true,
                part1AverageScore: 0.85,
                part2AverageScore: 0.85,
                part3AverageScore: 0.85
            ),
            isExpanded: .constant(true),
            onNavigate: {}
        )
    }
    .padding()
    .prostBackground()
}

#Preview("Started - Needs Work") {
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
