//
//  GoetheA1ExamView.swift
//  Prost
//
//  Main exam-taking interface for Goethe A1 Reading exams
//

import SwiftUI

struct GoetheA1ExamView: View {
    let exam: GoetheA1ReadingExam
    
    @EnvironmentObject private var appState: AppState
    @State private var selectedAnswers: [UUID: UUID] = [:] // [questionID: selectedOptionID]
    @State private var showResults = false
    @State private var currentCompletion: GoetheA1ExamCompletion?
    @State private var examResult: GoetheA1ExamResult?
    @Environment(\.dismiss) private var dismiss
    
    private var allQuestions: [GoetheA1Question] {
        exam.allQuestions
    }
    
    private var unansweredCount: Int {
        allQuestions.filter { selectedAnswers[$0.id] == nil }.count
    }
    
    private var canSubmit: Bool {
        unansweredCount == 0
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Exam header
                VStack(alignment: .leading, spacing: 8) {
                    Text(exam.title)
                        .font(ProstTheme.Typography.hero)
                    
                    HStack(spacing: 16) {
                        Label("\(exam.parts.count) Parts", systemImage: "doc.text")
                        Label("\(exam.totalQuestions) Questions", systemImage: "questionmark.circle")
                        Label("\(exam.duration) min", systemImage: "clock")
                    }
                    .font(ProstTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                }
                .prostCard()
                
                // Parts and questions
                ForEach(exam.parts) { part in
                    VStack(alignment: .leading, spacing: 16) {
                        // Part header
                        VStack(alignment: .leading, spacing: 4) {
                            Text(part.title)
                                .font(ProstTheme.Typography.title)
                                .foregroundStyle(.primary)
                            
                            Text(part.instructions)
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(part.questionRange)
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Texts for this part
                        ForEach(part.texts) { text in
                            VStack(alignment: .leading, spacing: 8) {
                                if let title = text.title {
                                    Text(title)
                                        .font(ProstTheme.Typography.title)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(text.content)
                                    .font(ProstTheme.Typography.body)
                                    .foregroundStyle(.primary)
                                    .lineSpacing(4)
                                    .textSelection(.enabled)
                            }
                            .prostCard()
                        }
                        
                        // Questions for this part
                        ForEach(part.questions) { question in
                            GoetheQuestionCardView(
                                question: question,
                                number: question.questionNumber,
                                selectedOptionID: Binding(
                                    get: { selectedAnswers[question.id] },
                                    set: { newValue in selectedAnswers[question.id] = newValue }
                                )
                            )
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("A1 Exam")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // Progress indicator
                if unansweredCount > 0 {
                    Text("\(unansweredCount) question\(unansweredCount == 1 ? "" : "s") remaining")
                        .font(ProstTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Submit button
                Button {
                    submitExam()
                } label: {
                    Text(canSubmit ? "Submit Exam" : "Answer all questions (\(unansweredCount) left)")
                        .font(ProstTheme.Typography.title)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canSubmit)
            }
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
        .navigationDestination(isPresented: $showResults) {
            if let completion = currentCompletion, let result = examResult {
                GoetheA1ResultsView(
                    exam: exam,
                    result: result,
                    completion: completion,
                    onRetake: {
                        selectedAnswers = [:]
                        currentCompletion = nil
                        examResult = nil
                        showResults = false
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitExam() {
        // Build results for each question
        var questionResults: [GoetheA1QuestionResult] = []
        
        for question in allQuestions {
            let result = GoetheA1QuestionResult(
                question: question,
                selectedOptionID: selectedAnswers[question.id]
            )
            questionResults.append(result)
        }
        
        // Build part results
        var partResults: [GoetheA1PartResult] = []
        
        for part in exam.parts {
            let partQuestionResults = questionResults.filter { result in
                part.questions.contains { $0.id == result.question.id }
            }
            
            let partResult = GoetheA1PartResult(
                partNumber: part.partNumber,
                questionResults: partQuestionResults
            )
            partResults.append(partResult)
        }
        
        // Create exam result
        let result = GoetheA1ExamResult(
            examId: exam.id,
            partResults: partResults
        )
        
        // Calculate attempt number
        let attemptNumber = appState.getNextGoetheAttemptNumber(for: exam.id)
        
        // Create completion record
        let completion = GoetheA1ExamCompletion(
            userId: appState.currentUser.id,
            examId: exam.id,
            level: exam.level,
            score: result.overallScore,
            isPassed: result.isPassed,
            attemptNumber: attemptNumber
        )
        
        // Save to app state
        appState.addGoetheCompletion(completion, result: result)
        
        // Store for navigation
        currentCompletion = completion
        examResult = result
        
        // Navigate to results
        showResults = true
    }
}

#Preview {
    NavigationStack {
        GoetheA1ExamView(exam: .fromSeedData)
            .environmentObject(AppState())
    }
}

