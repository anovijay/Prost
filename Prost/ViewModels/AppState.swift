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
        updateProgress(for: passage.level, newCompletion: completion)
    }
    
    /// Get completion history for a specific passage
    func completionHistory(for passageId: UUID) -> [PassageCompletion] {
        completions
            .filter { $0.passageId == passageId && $0.userId == currentUser.id }
            .sorted { $0.completedAt < $1.completedAt }
    }
    
    /// Check if a passage has been completed
    func isCompleted(_ passageId: UUID) -> Bool {
        completions.contains { $0.passageId == passageId && $0.userId == currentUser.id }
    }
    
    /// Get next attempt number for a passage
    func getNextAttemptNumber(for passageId: UUID) -> Int {
        let existingAttempts = completions.filter {
            $0.passageId == passageId && $0.userId == currentUser.id
        }
        return existingAttempts.count + 1
    }
    
    /// Compare new score with previous attempts
    func compareScore(for passageId: UUID, newScore: Double) -> ScoreComparison {
        let previousCompletions = completionHistory(for: passageId).filter { $0.score != newScore }
        
        guard !previousCompletions.isEmpty else {
            return .first
        }
        
        let previousBest = previousCompletions.map { $0.score }.max() ?? 0
        
        if newScore > previousBest {
            return .improved
        } else if newScore < previousBest {
            return .declined
        } else {
            return .same
        }
    }
    
    // MARK: - Private Methods
    
    /// Update user progress after a completion
    private func updateProgress(for level: String, newCompletion: PassageCompletion) {
        let userId = currentUser.id
        
        // Get all completions for this level and user
        let levelCompletions = completions.filter {
            $0.userId == userId && $0.level == level
        }
        
        // Calculate stats
        let completedPassageIds = Set(levelCompletions.map { $0.passageId })
        let totalAttempts = levelCompletions.count
        let averageScore = levelCompletions.isEmpty ? 0.0 : levelCompletions.map { $0.score }.reduce(0, +) / Double(levelCompletions.count)
        let bestScore = levelCompletions.map { $0.score }.max() ?? 0.0
        let latestScore = newCompletion.score
        
        // Update or create progress
        if let index = userProgress.firstIndex(where: { $0.level == level && $0.userId == userId }) {
            userProgress[index] = UserProgress(
                id: userProgress[index].id,
                userId: userId,
                level: level,
                completedPassageIds: Array(completedPassageIds),
                totalAttempts: totalAttempts,
                averageScore: averageScore,
                bestScore: bestScore,
                latestScore: latestScore,
                lastActivityAt: Date()
            )
        } else {
            let newProgress = UserProgress(
                userId: userId,
                level: level,
                completedPassageIds: Array(completedPassageIds),
                totalAttempts: totalAttempts,
                averageScore: averageScore,
                bestScore: bestScore,
                latestScore: latestScore,
                lastActivityAt: Date()
            )
            userProgress.append(newProgress)
        }
    }
}

// MARK: - Score Comparison

enum ScoreComparison {
    case first       // First attempt
    case improved    // Better than previous best
    case declined    // Worse than previous best
    case same        // Same as previous best
}

