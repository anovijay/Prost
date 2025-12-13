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
    let onRetake: () -> Void

    private var correctCount: Int { results.filter(\.isCorrect).count }
    private var wrongResults: [ReadingQuestionResult] { results.filter { !$0.isCorrect } }
    private var scorePercentage: Int { Int((Double(correctCount) / Double(results.count)) * 100) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Score summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(scorePercentage)%")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)
                    Text("\(correctCount) of \(results.count) correct")
                        .font(ProstTheme.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .prostCard()

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
}
