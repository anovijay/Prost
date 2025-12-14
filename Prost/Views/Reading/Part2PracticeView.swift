//
//  Part2PracticeView.swift
//  Prost
//
//  View for taking A1 Part 2 situation-based practice (A/B choice)
//

import SwiftUI

struct Part2PracticeView: View {
    let passage: ReadingPassage
    
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOptionID: UUID?
    @State private var showResults = false
    @State private var completion: PassageCompletion?
    
    // Extract situation and texts from the question prompt
    private var situationComponents: (situation: String, textA: String, textB: String)? {
        guard let question = passage.questions.first else { return nil }
        
        // The prompt contains the full text formatted as:
        // Situation\n\nText A:\nTextA content\n\nText B:\nTextB content
        let components = question.prompt.components(separatedBy: "\n\n")
        guard components.count >= 3 else { return nil }
        
        let situation = components[0]
        let textA = components[1].replacingOccurrences(of: "Text A:\n", with: "")
        let textB = components[2].replacingOccurrences(of: "Text B:\n", with: "")
        
        return (situation, textA, textB)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: ProstTheme.Spacing.section) {
                if let components = situationComponents, let question = passage.questions.first {
                    // Situation
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Situation")
                            .font(ProstTheme.Typography.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        Text(components.situation)
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.primary)
                            .padding(ProstTheme.Spacing.item)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ProstTheme.Colors.accentSoft)
                            .cornerRadius(ProstTheme.Radius.card)
                    }
                    
                    // Text A
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Text A")
                                .font(ProstTheme.Typography.title.weight(.bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedOptionID == question.options.first?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.accentColor)
                            }
                        }
                        
                        Text(components.textA)
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                    }
                    .padding(ProstTheme.Spacing.item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedOptionID == question.options.first?.id ? ProstTheme.Colors.accentSoft : ProstTheme.Colors.card)
                    .cornerRadius(ProstTheme.Radius.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: ProstTheme.Radius.card)
                            .stroke(selectedOptionID == question.options.first?.id ? ProstTheme.Colors.accentBorder : ProstTheme.Colors.cardBorder, lineWidth: selectedOptionID == question.options.first?.id ? 2 : 1)
                    )
                    .onTapGesture {
                        selectedOptionID = question.options.first?.id
                    }
                    
                    // Text B
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Text B")
                                .font(ProstTheme.Typography.title.weight(.bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            if selectedOptionID == question.options.last?.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.accentColor)
                            }
                        }
                        
                        Text(components.textB)
                            .font(ProstTheme.Typography.body)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                    }
                    .padding(ProstTheme.Spacing.item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(selectedOptionID == question.options.last?.id ? ProstTheme.Colors.accentSoft : ProstTheme.Colors.card)
                    .cornerRadius(ProstTheme.Radius.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: ProstTheme.Radius.card)
                            .stroke(selectedOptionID == question.options.last?.id ? ProstTheme.Colors.accentBorder : ProstTheme.Colors.cardBorder, lineWidth: selectedOptionID == question.options.last?.id ? 2 : 1)
                    )
                    .onTapGesture {
                        selectedOptionID = question.options.last?.id
                    }
                    
                    Spacer(minLength: 80)
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle(passage.title)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .safeAreaInset(edge: .bottom) {
            Button {
                submitAnswer()
            } label: {
                Text(selectedOptionID == nil ? "Select an option" : "Submit Answer")
                    .font(ProstTheme.Typography.title)
                    .frame(maxWidth: .infinity)
                    .padding(16)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedOptionID == nil)
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
        .navigationDestination(isPresented: $showResults) {
            if let completion = completion {
                ReadingResultsView(
                    passage: passage,
                    completion: completion,
                    onRetake: {
                        selectedOptionID = nil
                        self.completion = nil
                        showResults = false
                    }
                )
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitAnswer() {
        guard let question = passage.questions.first else { return }
        
        let isCorrect = question.isCorrect(selectedOptionID: selectedOptionID)
        let score = isCorrect ? 1.0 : 0.0
        
        // Create completion
        let attemptNumber = appState.nextAttemptNumber(for: passage.id)
        let newCompletion = PassageCompletion(
            userId: appState.currentUser.id,
            passageId: passage.id,
            level: passage.level,
            score: score,
            attemptNumber: attemptNumber
        )
        
        // Record completion
        appState.recordCompletion(for: passage, score: score)
        completion = newCompletion
        showResults = true
    }
}

#Preview {
    NavigationStack {
        Part2PracticeView(passage: ReadingPassage(
            title: "Practice 1: Supermarket",
            level: "A1",
            text: "Sie möchten am Samstagvormittag einkaufen und mit Karte bezahlen.",
            questions: [
                ReadingQuestion(
                    prompt: "Sie möchten am Samstagvormittag einkaufen und mit Karte bezahlen.\n\nText A:\nSupermarkt Nord\nSamstag: 8:00–12:00\nNur Barzahlung\n\nText B:\nSupermarkt Süd\nSamstag: 9:00–18:00\nKartenzahlung möglich",
                    options: [
                        ReadingOption(text: "Text A"),
                        ReadingOption(text: "Text B")
                    ],
                    correctOptionID: UUID()
                )
            ],
            tags: ["part2", "situation"]
        ))
        .environmentObject(AppState())
    }
}

