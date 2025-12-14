//
//  AppState.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation
import SwiftUI
import Combine

/// App-wide state management for user data and completions
/// Note: In-memory storage only. Will be replaced with Core Data in Phase 4.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Published State

    @Published var currentUser: User
    @Published var completions: [PassageCompletion]
    @Published var userProgress: [UserProgress]
    @Published var vocabularyWords: [VocabularyWord] = []
    
    // MARK: - Initialization
    
    init(
        currentUser: User,
        completions: [PassageCompletion],
        userProgress: [UserProgress],
        vocabularyWords: [VocabularyWord] = []
    ) {
        self.currentUser = currentUser
        self.completions = completions
        self.userProgress = userProgress
        self.vocabularyWords = vocabularyWords
    }
    
    // Convenience initializer with sample data
    convenience init() {
        self.init(
            currentUser: User.sampleUser,
            completions: PassageCompletion.sampleCompletions,
            userProgress: UserProgress.sampleProgress
        )
    }
    
}

