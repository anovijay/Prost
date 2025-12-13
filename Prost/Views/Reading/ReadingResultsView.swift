//
//  ReadingResultsView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingResultsView: View {
    let passage: ReadingPassage
    let results: [ReadingQuestionResult]
    let completion: PassageCompletion
    let onRetake: () -> Void
    
    @EnvironmentObject private var appState: AppState
    @State private var showHistory = false

    private var correctCount: Int { results.filter(\.isCorrect).count }
    private var wrongResults: [ReadingQuestionResult] { results.filter { !$0.isCorrect } }
    private var scorePercentage: Int { completion.scorePercentage }
    
    private var completionHistory: [PassageCompletion] {
        appState.getCompletionHistory(for: passage.id)
    }
    
    private var previousCompletions: [PassageCompletion] {
        completionHistory.filter { $0.id != completion.id }
    }
    
    private var scoreComparison: CompletionService.ScoreComparison {
        CompletionService.getScoreComparison(
            newScore: completion.score,
            previousCompletions: previousCompletions
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Attempt badge
                HStack {
                    Image(systemName: "number.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Attempt #\(completion.attemptNumber)")
                        .font(ProstTheme.Typography.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Spacer()
                    if completionHistory.count > 1 {
                        Button {
                            showHistory.toggle()
                        } label: {
                            HStack(spacing: 4) {
                                Text("History")
                                    .font(ProstTheme.Typography.caption)
                                Image(systemName: showHistory ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Score summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(scorePercentage)%")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)
                    Text("\(correctCount) of \(results.count) correct")
                        .font(ProstTheme.Typography.body)
                        .foregroundStyle(.secondary)
                    
                    // Score comparison message
                    Text(scoreComparison.message)
                        .font(ProstTheme.Typography.body.weight(.medium))
                        .foregroundStyle(messageColor(for: scoreComparison))
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .prostCard()
                
                // Attempt history (expandable)
                if showHistory && completionHistory.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attempt History")
                            .font(ProstTheme.Typography.title)
                            .padding(.horizontal, 4)
                        
                        ForEach(completionHistory.reversed()) { historyCompletion in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text("Attempt #\(historyCompletion.attemptNumber)")
                                            .font(ProstTheme.Typography.body.weight(.semibold))
                                        if historyCompletion.id == completion.id {
                                            Text("(Current)")
                                                .font(ProstTheme.Typography.caption)
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    Text(historyCompletion.completedAt, style: .relative)
                                        .font(ProstTheme.Typography.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text("\(historyCompletion.scorePercentage)%")
                                        .font(ProstTheme.Typography.body.weight(.bold))
                                    if historyCompletion.isPerfect {
                                        Image(systemName: "star.fill")
                                            .font(.caption)
                                            .foregroundStyle(.yellow)
                                    }
                                }
                            }
                            .padding(12)
                            .background(historyCompletion.id == completion.id ? Color.blue.opacity(0.08) : Color.clear)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                    .prostCard()
                }

                // Wrong answers review
                if !wrongResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review")
                            .font(ProstTheme.Typography.title)
                            .padding(.horizontal, 4)

                        ForEach(wrongResults) { r in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(r.question.prompt)
                                    .font(ProstTheme.Typography.body.weight(.semibold))

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(ProstTheme.Colors.danger)
                                        Text(r.selectedOptionText ?? "No answer")
                                            .font(ProstTheme.Typography.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(ProstTheme.Colors.success)
                                        Text(r.correctOptionText)
                                            .font(ProstTheme.Typography.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .prostCard()
                        }
                    }
                } else {
                    // Perfect score celebration
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text("Perfect Score!")
                            .font(ProstTheme.Typography.body.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                }

                Spacer(minLength: 80)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle(passage.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                onRetake()
            } label: {
                Text("Retake")
                    .font(ProstTheme.Typography.title)
                    .frame(maxWidth: .infinity)
                    .padding(16)
            }
            .buttonStyle(.borderedProminent)
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Helpers
    
    private func messageColor(for comparison: CompletionService.ScoreComparison) -> Color {
        switch comparison {
        case .firstAttempt:
            return .primary
        case .improved:
            return .green
        case .decreased:
            return .orange
        case .same:
            return .primary
        }
    }
}
