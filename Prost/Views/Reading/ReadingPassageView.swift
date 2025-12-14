//
//  ReadingPassageView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingPassageView: View {
    let passage: ReadingPassage
    
    @EnvironmentObject private var appState: AppState
    @State private var goToQuestions = false
    @State private var showManualCompleteConfirmation = false
    @State private var showSuccessMessage = false
    @State private var showAddWordSheet = false
    @State private var showWordSavedAlert = false
    @State private var savedWordText = ""
    
    private var isAlreadyCompleted: Bool {
        appState.isCompleted(passage.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Completion badge if already completed
                if isAlreadyCompleted {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Completed")
                            .font(ProstTheme.Typography.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(passage.text)
                        .font(ProstTheme.Typography.body)
                        .foregroundStyle(.primary)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                        .prostCard()
                    
                    // Quick add word button
                    Button {
                        showAddWordSheet = true
                    } label: {
                        Label("Add Word to List", systemImage: "plus.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 80)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 12) {
                // Primary action: Continue to questions
                Button {
                    goToQuestions = true
                } label: {
                    Text("Continue to Questions")
                        .font(ProstTheme.Typography.title)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                }
                .buttonStyle(.borderedProminent)
                
                // Secondary action: Mark as complete
                if !isAlreadyCompleted {
                    Button {
                        showManualCompleteConfirmation = true
                    } label: {
                        Text("Mark as Complete")
                            .font(ProstTheme.Typography.body)
                            .frame(maxWidth: .infinity)
                            .padding(12)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(passage.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .navigationDestination(isPresented: $goToQuestions) {
            ReadingQuestionsView(passage: passage)
        }
        .sheet(isPresented: $showAddWordSheet) {
            AddWordToListSheet(
                passage: passage,
                onSave: { word, context, notes in
                    let vocabularyWord = VocabularyWord(
                        userId: appState.currentUser.id,
                        word: word,
                        context: context,
                        sourcePassageId: passage.id,
                        sourcePassageTitle: passage.title,
                        level: passage.level,
                        notes: notes
                    )
                    appState.addWord(vocabularyWord)
                    savedWordText = word
                    showWordSavedAlert = true
                }
            )
        }
        .alert("Word Saved!", isPresented: $showWordSavedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("'\(savedWordText)' has been added to your word list.")
        }
        .alert("Mark as Complete?", isPresented: $showManualCompleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Complete") {
                markAsComplete()
            }
        } message: {
            Text("This will mark the passage as completed without answering questions (perfect score).")
        }
        .alert("Completed!", isPresented: $showSuccessMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Passage marked as complete with perfect score!")
        }
    }
    
    // MARK: - Actions
    
    private func markAsComplete() {
        _ = appState.recordCompletion(for: passage, score: 1.0)
        showSuccessMessage = true
    }
}
