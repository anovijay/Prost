//
//  VocabularyService.swift
//  Prost
//
//  Service for managing user's vocabulary word list
//

import Foundation

extension AppState {
    
    // MARK: - Vocabulary Management
    
    /// Add a new word to the vocabulary list
    func addWord(_ word: VocabularyWord) {
        // Check if word already exists
        guard !vocabularyWords.contains(where: { $0.word.lowercased() == word.word.lowercased() && $0.userId == word.userId }) else {
            return
        }
        vocabularyWords.append(word)
    }
    
    /// Remove a word from the vocabulary list
    func removeWord(_ wordId: UUID) {
        vocabularyWords.removeAll { $0.id == wordId }
    }
    
    /// Toggle favorite status of a word
    func toggleFavorite(_ wordId: UUID) {
        if let index = vocabularyWords.firstIndex(where: { $0.id == wordId }) {
            vocabularyWords[index].isFavorite.toggle()
        }
    }
    
    /// Update notes for a word
    func updateWordNotes(_ wordId: UUID, notes: String?) {
        if let index = vocabularyWords.firstIndex(where: { $0.id == wordId }) {
            vocabularyWords[index].notes = notes
        }
    }
    
    /// Get all words for current user
    func getUserWords() -> [VocabularyWord] {
        vocabularyWords
            .filter { $0.userId == currentUser.id }
            .sorted { $0.addedAt > $1.addedAt }  // Most recent first
    }
    
    /// Get words filtered by level
    func getWords(forLevel level: String) -> [VocabularyWord] {
        getUserWords().filter { $0.level == level }
    }
    
    /// Get favorite words only
    func getFavoriteWords() -> [VocabularyWord] {
        getUserWords().filter { $0.isFavorite }
    }
    
    /// Search words by text
    func searchWords(query: String) -> [VocabularyWord] {
        guard !query.isEmpty else { return getUserWords() }
        let lowercaseQuery = query.lowercased()
        return getUserWords().filter { 
            $0.word.lowercased().contains(lowercaseQuery) ||
            $0.context.lowercased().contains(lowercaseQuery) ||
            ($0.notes?.lowercased().contains(lowercaseQuery) ?? false)
        }
    }
    
    /// Check if a word is already saved
    func isWordSaved(_ word: String) -> Bool {
        vocabularyWords.contains { 
            $0.word.lowercased() == word.lowercased() && 
            $0.userId == currentUser.id 
        }
    }
}

