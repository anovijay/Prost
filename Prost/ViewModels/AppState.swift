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
    
    // MARK: - Initialization
    
    init(
        currentUser: User,
        completions: [PassageCompletion],
        userProgress: [UserProgress]
    ) {
        self.currentUser = currentUser
        self.completions = completions
        self.userProgress = userProgress
    }
    
    // Convenience initializer with sample data
    convenience init() {
        self.init(
            currentUser: User.sampleUser,
            completions: PassageCompletion.sampleCompletions,
            userProgress: UserProgress.sampleProgress
        )
    }
    
    // MARK: - Passage Completion Methods
    
    /// Add a passage completion and update progress
    func addCompletion(_ completion: PassageCompletion, for passage: ReadingPassage) {
        completions.append(completion)
        
        // Update or create progress for this level
        userProgress = CompletionService.updateProgress(
            currentProgress: userProgress,
            newCompletion: completion,
            allCompletions: completions,
            userId: currentUser.id
        )
    }
    
    /// Get completion history for a specific passage
    func completionHistory(for passageId: UUID) -> [PassageCompletion] {
        CompletionService.getCompletionHistory(
            userId: currentUser.id,
            passageId: passageId,
            allCompletions: completions
        )
    }
    
    /// Check if a passage has been completed
    func isCompleted(_ passageId: UUID) -> Bool {
        CompletionService.isCompleted(
            userId: currentUser.id,
            passageId: passageId,
            allCompletions: completions
        )
    }
    
    /// Get next attempt number for a passage
    func getNextAttemptNumber(for passageId: UUID) -> Int {
        CompletionService.calculateAttemptNumber(
            userId: currentUser.id,
            passageId: passageId,
            existingCompletions: completions
        )
    }
    
    /// Compare new score with previous attempts
    func compareScore(for passageId: UUID, newScore: Double) -> CompletionService.ScoreComparison {
        let previousCompletions = completionHistory(for: passageId).filter { $0.score != newScore }
        return CompletionService.getScoreComparison(
            newScore: newScore,
            previousCompletions: previousCompletions
        )
    }
    
}

