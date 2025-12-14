//
//  GoetheA1ResultsView.swift
//  Prost
//
//  Display Goethe A1 exam results with score breakdown and review
//

import SwiftUI

struct GoetheA1ResultsView: View {
    let exam: GoetheA1ReadingExam
    let result: GoetheA1ExamResult
    let completion: GoetheA1ExamCompletion
    let onRetake: () -> Void
    
    @EnvironmentObject private var appState: AppState
    @State private var showHistory = false
    
    private var correctCount: Int { result.correctCount }
    private var totalCount: Int { result.totalCount }
    private var scorePercentage: Int { result.overallScorePercentage }
    private var isPassed: Bool { result.isPassed }
    
    private var wrongResults: [GoetheA1QuestionResult] {
        result.allQuestionResults.filter { !$0.isCorrect }
    }
    
    private var completionHistory: [GoetheA1ExamCompletion] {
        appState.goetheCompletionHistory(for: exam.id)
    }
    
    private var scoreComparison: String {
        let previousCompletions = completionHistory.filter { $0.id != completion.id }
        
        guard let previousBest = previousCompletions.map({ $0.scorePercentage }).max() else {
            return "First attempt complete! 🎉"
        }
        
        if scorePercentage > previousBest {
            return "Improved from \(previousBest)% to \(scorePercentage)%! 🎉"
        } else if scorePercentage < previousBest {
            return "Previous best: \(previousBest)%"
        } else {
            return "Same as previous attempt"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Attempt badge
                HStack {
                    Image(systemName: "number.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Attempt #\(completion.attemptNumber)")
                        .font(ProstTheme.Typography.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if completionHistory.count > 1 {
                        Button {
                            showHistory.toggle()
                        } label: {
                            Label("History", systemImage: showHistory ? "chevron.up" : "chevron.down")
                                .font(ProstTheme.Typography.caption)
                        }
                    }
                }
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // History section (if toggled)
                if showHistory && completionHistory.count > 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Previous Attempts")
                            .font(ProstTheme.Typography.title)
                        
                        ForEach(completionHistory) { comp in
                            HStack {
                                Text("Attempt #\(comp.attemptNumber)")
                                    .font(ProstTheme.Typography.body)
                                    .foregroundStyle(comp.id == completion.id ? .primary : .secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text("\(comp.scorePercentage)%")
                                        .font(ProstTheme.Typography.body.weight(.medium))
                                    
                                    if comp.isPassed {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    }
                                    
                                    if comp.isPerfect {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                .foregroundStyle(comp.id == completion.id ? .primary : .secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .prostCard()
                }
                
                // Overall score card
                VStack(spacing: 16) {
                    // Pass/Fail badge
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: isPassed ? "checkmark.seal.fill" : "xmark.seal.fill")
                                .font(.title2)
                            Text(isPassed ? "PASSED" : "NOT PASSED")
                                .font(ProstTheme.Typography.title.weight(.bold))
                        }
                        .foregroundStyle(isPassed ? .green : .orange)
                        
                        Spacer()
                    }
                    .padding(16)
                    .background(isPassed ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Score
                    VStack(spacing: 8) {
                        Text("\(scorePercentage)%")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(isPassed ? .green : .orange)
                        
                        Text("\(correctCount) / \(totalCount) correct")
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.secondary)
                        
                        Text(scoreComparison)
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(scorePercentage > (completionHistory.filter { $0.id != completion.id }.map({ $0.scorePercentage }).max() ?? 0) ? .green : .secondary)
                    }
                    
                    Divider()
                    
                    // Pass threshold info
                    HStack {
                        Text("Pass threshold: 60%")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(isPassed ? "You passed! ✓" : "Keep practicing")
                            .font(ProstTheme.Typography.caption.weight(.medium))
                            .foregroundStyle(isPassed ? .green : .orange)
                    }
                }
                .prostCard()
                
                // Part breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Performance by Part")
                        .font(ProstTheme.Typography.title)
                    
                    ForEach(result.partResults) { partResult in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Part \(partResult.partNumber)")
                                    .font(ProstTheme.Typography.body.weight(.medium))
                                
                                Text("\(partResult.correctCount) / \(partResult.totalCount) correct")
                                    .font(ProstTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text("\(partResult.scorePercentage)%")
                                    .font(ProstTheme.Typography.title.weight(.bold))
                                    .foregroundStyle(partResult.scorePercentage >= 60 ? .green : .orange)
                                
                                if partResult.scorePercentage >= 80 {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if partResult.scorePercentage >= 60 {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
                .prostCard()
                
                // Review wrong answers
                if completion.isPerfect {
                    // Perfect score celebration
                    VStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.yellow)
                        
                        Text("Perfect Score!")
                            .font(ProstTheme.Typography.title)
                        
                        Text("You answered all questions correctly! 🎉")
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(12)
                } else if !wrongResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review Incorrect Answers")
                            .font(ProstTheme.Typography.title)
                        
                        Text("\(wrongResults.count) question\(wrongResults.count == 1 ? "" : "s") to review")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                        
                        ForEach(wrongResults) { questionResult in
                            VStack(alignment: .leading, spacing: 12) {
                                // Question
                                HStack(alignment: .top, spacing: 8) {
                                    Text("Q\(questionResult.question.questionNumber)")
                                        .font(ProstTheme.Typography.title)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(questionResult.question.prompt)
                                        .font(ProstTheme.Typography.body)
                                        .foregroundStyle(.primary)
                                }
                                
                                // User's wrong answer
                                if let selectedText = questionResult.selectedOptionText {
                                    HStack(spacing: 8) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Your answer:")
                                                .font(ProstTheme.Typography.caption)
                                                .foregroundStyle(.secondary)
                                            Text(selectedText)
                                                .font(ProstTheme.Typography.body)
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(8)
                                }
                                
                                // Correct answer
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Correct answer:")
                                            .font(ProstTheme.Typography.caption)
                                            .foregroundStyle(.secondary)
                                        Text(questionResult.correctOptionText)
                                            .font(ProstTheme.Typography.body)
                                    }
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .prostCard()
                        }
                    }
                }
                
                Spacer(minLength: 80)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                onRetake()
            } label: {
                Text("Retake Exam")
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

#Preview {
    let exam = GoetheA1ReadingExam.fromSeedData
    let completion = GoetheA1ExamCompletion.sampleCompletion
    
    // Create sample result
    let part1Result = GoetheA1PartResult(
        partNumber: 1,
        questionResults: []
    )
    
    let result = GoetheA1ExamResult(
        examId: exam.id,
        partResults: [part1Result]
    )
    
    return NavigationStack {
        GoetheA1ResultsView(
            exam: exam,
            result: result,
            completion: completion,
            onRetake: {}
        )
        .environmentObject(AppState())
    }
}

