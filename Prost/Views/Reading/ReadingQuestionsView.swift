//
//  ReadingQuestionsView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingQuestionsView: View {
    let passage: ReadingPassage

    @State private var selectedOptionByQuestionID: [UUID: UUID] = [:]
    @State private var showResults = false

    private var results: [ReadingQuestionResult] {
        passage.questions.map { q in
            ReadingQuestionResult(question: q, selectedOptionID: selectedOptionByQuestionID[q.id])
        }
    }

    private var unansweredCount: Int {
        results.filter { $0.selectedOptionID == nil }.count
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
                showResults = true
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
            ReadingResultsView(
                passage: passage,
                results: results,
                onRetake: {
                    selectedOptionByQuestionID = [:]
                    showResults = false
                }
            )
        }
    }
}
