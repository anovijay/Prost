//
//  WordListView.swift
//  Prost
//
//  View for displaying and managing user's vocabulary word list
//

import SwiftUI

struct WordListView: View {
    @EnvironmentObject private var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter: WordFilter = .all
    @State private var selectedWord: VocabularyWord?
    @State private var showEditSheet = false
    
    private var filteredWords: [VocabularyWord] {
        let words: [VocabularyWord]
        
        switch selectedFilter {
        case .all:
            words = appState.getUserWords()
        case .favorites:
            words = appState.getFavoriteWords()
        case .level(let level):
            words = appState.getWords(forLevel: level)
        }
        
        if searchText.isEmpty {
            return words
        } else {
            return words.filter {
                $0.word.lowercased().contains(searchText.lowercased()) ||
                $0.context.lowercased().contains(searchText.lowercased()) ||
                ($0.notes?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Picker
                Picker("Filter", selection: $selectedFilter) {
                    Text("All (\(appState.getUserWords().count))").tag(WordFilter.all)
                    Text("Favorites").tag(WordFilter.favorites)
                    Text("A1").tag(WordFilter.level("A1"))
                    Text("A2").tag(WordFilter.level("A2"))
                    Text("B1").tag(WordFilter.level("B1"))
                    Text("B2").tag(WordFilter.level("B2"))
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Word List
                if filteredWords.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredWords) { word in
                            WordRowView(word: word)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedWord = word
                                    showEditSheet = true
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        appState.removeWord(word.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        appState.toggleFavorite(word.id)
                                    } label: {
                                        Label(
                                            word.isFavorite ? "Unfavorite" : "Favorite",
                                            systemImage: word.isFavorite ? "star.slash" : "star.fill"
                                        )
                                    }
                                    .tint(.yellow)
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Word List")
            .searchable(text: $searchText, prompt: "Search words...")
            .sheet(isPresented: $showEditSheet) {
                if let word = selectedWord {
                    WordDetailSheet(word: word)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text(searchText.isEmpty ? "No Words Yet" : "No Results")
                .font(.title2.weight(.semibold))
            
            Text(searchText.isEmpty 
                 ? "Start adding words from practice texts to build your vocabulary list"
                 : "Try a different search term")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Word Row View

struct WordRowView: View {
    let word: VocabularyWord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.word)
                    .font(.title3.weight(.semibold))
                
                Spacer()
                
                if word.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                
                Text(word.level)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text(word.context)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("From: \(word.sourcePassageTitle)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                Spacer()
                
                Text(word.addedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            if let notes = word.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Word Detail Sheet

struct WordDetailSheet: View {
    let word: VocabularyWord
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var notes: String
    @State private var isFavorite: Bool
    
    init(word: VocabularyWord) {
        self.word = word
        _notes = State(initialValue: word.notes ?? "")
        _isFavorite = State(initialValue: word.isFavorite)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Word") {
                    Text(word.word)
                        .font(.title2.weight(.semibold))
                }
                
                Section("Context") {
                    Text(word.context)
                        .font(.body)
                }
                
                Section("Source") {
                    LabeledContent("From", value: word.sourcePassageTitle)
                    LabeledContent("Level", value: word.level)
                    LabeledContent("Added", value: word.addedAt.formatted(date: .abbreviated, time: .shortened))
                }
                
                Section {
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(role: .destructive) {
                        appState.removeWord(word.id)
                        dismiss()
                    } label: {
                        Label("Delete Word", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Word Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.updateWordNotes(word.id, notes: notes.isEmpty ? nil : notes)
                        if isFavorite != word.isFavorite {
                            appState.toggleFavorite(word.id)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Types

enum WordFilter: Hashable {
    case all
    case favorites
    case level(String)
}

#Preview {
    WordListView()
        .environmentObject(AppState())
}

