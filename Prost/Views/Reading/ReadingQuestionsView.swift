//
//  ReadingQuestionsView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingQuestionsView: View {
    let passage: ReadingPassage
    
    @EnvironmentObject private var appState: AppState
    @State private var selectedOptionByQuestionID: [UUID: UUID] = [:]
    @State private var showResults = false
    @State private var currentCompletion: PassageCompletion?

    private var results: [ReadingQuestionResult] {
        passage.questions.map { q in
            ReadingQuestionResult(question: q, selectedOptionID: selectedOptionByQuestionID[q.id])
        }
    }

    private var unansweredCount: Int {
        results.filter { $0.selectedOptionID == nil }.count
    }
    
    private var score: Double {
        let correctCount = results.filter { $0.isCorrect }.count
        return Double(correctCount) / Double(passage.questions.count)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(passage.questions.enumerated()), id: \.element.id) { idx, q in
                    QuestionCardView(
                        number: idx + 1,
                        question: q,
                        selectedOptionID: Binding(
                            get: { selectedOptionByQuestionID[q.id] },
                            set: { newValue in selectedOptionByQuestionID[q.id] = newValue }
                        )
                    )
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
                submitAnswers()
            } label: {
                Text(unansweredCount > 0 ? "Answer all questions (\(unansweredCount) left)" : "Submit Answers")
                    .font(ProstTheme.Typography.title)
                    .frame(maxWidth: .infinity)
                    .padding(16)
            }
            .buttonStyle(.borderedProminent)
            .disabled(unansweredCount > 0)
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
        .navigationDestination(isPresented: $showResults) {
            if let completion = currentCompletion {
                ReadingResultsView(
                    passage: passage,
                    results: results,
                    completion: completion,
                    onRetake: {
                        selectedOptionByQuestionID = [:]
                        currentCompletion = nil
                        showResults = false
                    }
                )
            }
        }
    }
    
    // MARK: - Actions

    private func submitAnswers() {
        currentCompletion = appState.recordCompletion(for: passage, score: score)
        showResults = true
    }
}
