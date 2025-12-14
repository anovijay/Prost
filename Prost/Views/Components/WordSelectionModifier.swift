//
//  WordSelectionModifier.swift
//  Prost
//
//  View modifier for selecting words and adding them to vocabulary list
//

import SwiftUI

struct WordSelectionModifier: ViewModifier {
    let passage: ReadingPassage
    @EnvironmentObject private var appState: AppState
    @State private var selectedWord: String?
    @State private var selectedContext: String?
    @State private var showWordSheet = false
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                if let word = selectedWord {
                    Button {
                        saveWord(word)
                    } label: {
                        Label("Add to Word List", systemImage: "plus.circle")
                    }
                    .disabled(appState.isWordSaved(word))
                }
            }
            .sheet(isPresented: $showWordSheet) {
                if let word = selectedWord, let context = selectedContext {
                    WordSaveSheet(
                        word: word,
                        context: context,
                        passage: passage,
                        onSave: { notes in
                            saveWord(word, notes: notes)
                        },
                        onCancel: {
                            showWordSheet = false
                        }
                    )
                }
            }
    }
    
    private func saveWord(_ word: String, notes: String? = nil) {
        let vocabularyWord = VocabularyWord(
            userId: appState.currentUser.id,
            word: word,
            context: selectedContext ?? passage.text,
            sourcePassageId: passage.id,
            sourcePassageTitle: passage.title,
            level: passage.level,
            notes: notes
        )
        appState.addWord(vocabularyWord)
        showWordSheet = false
    }
}

// MARK: - Word Save Sheet

struct WordSaveSheet: View {
    let word: String
    let context: String
    let passage: ReadingPassage
    let onSave: (String?) -> Void
    let onCancel: () -> Void
    
    @State private var notes: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Word") {
                    Text(word)
                        .font(.title2.weight(.semibold))
                }
                
                Section("Context") {
                    Text(context)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Section("Source") {
                    HStack {
                        Text("From:")
                        Spacer()
                        Text(passage.title)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Level:")
                        Spacer()
                        Text(passage.level)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(notes.isEmpty ? nil : notes)
                        dismiss()
                    }
                }
            }
        }
    }
}

extension View {
    func wordSelectionEnabled(passage: ReadingPassage) -> some View {
        modifier(WordSelectionModifier(passage: passage))
    }
}

