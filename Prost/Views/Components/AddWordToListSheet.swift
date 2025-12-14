//
//  AddWordToListSheet.swift
//  Prost
//
//  Sheet for manually adding a word to the vocabulary list
//

import SwiftUI

struct AddWordToListSheet: View {
    let passage: ReadingPassage
    let onSave: (String, String, String?) -> Void
    
    @State private var word = ""
    @State private var context = ""
    @State private var notes = ""
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isAlreadySaved: Bool {
        appState.isWordSaved(word)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Word", text: $word)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    if isAlreadySaved {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Already in word list")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Word")
                } footer: {
                    Text("Enter the German word you want to save")
                }
                
                Section {
                    TextField("Context (optional)", text: $context, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Context")
                } footer: {
                    Text("The sentence where you found this word")
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                } footer: {
                    Text("Translation, definition, or your own notes")
                }
                
                Section {
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
                } header: {
                    Text("Source")
                }
            }
            .navigationTitle("Add Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmedWord = word.trimmingCharacters(in: .whitespaces)
                        let trimmedContext = context.trimmingCharacters(in: .whitespaces)
                        let trimmedNotes = notes.trimmingCharacters(in: .whitespaces)
                        
                        onSave(
                            trimmedWord,
                            trimmedContext.isEmpty ? passage.text : trimmedContext,
                            trimmedNotes.isEmpty ? nil : trimmedNotes
                        )
                        dismiss()
                    }
                    .disabled(!canSave || isAlreadySaved)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    AddWordToListSheet(
        passage: ReadingPassage(
            title: "Practice 1",
            level: "A1",
            text: "Sample text",
            questions: []
        ),
        onSave: { _, _, _ in }
    )
    .environmentObject(AppState())
}

