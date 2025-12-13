//
//  CompletionService.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

/// Service responsible for handling passage completion logic and progress aggregation
struct CompletionService {
    
    // MARK: - Completion Creation
    
    /// Create a new passage completion record
    static func createCompletion(
        userId: UUID,
        passageId: UUID,
        level: String,
        score: Double,
        attemptNumber: Int
    ) -> PassageCompletion {
        PassageCompletion(
            userId: userId,
            passageId: passageId,
            level: level,
            score: score,
            completedAt: Date(),
            attemptNumber: attemptNumber
        )
    }
    
    /// Calculate the attempt number for a new completion
    static func calculateAttemptNumber(
        userId: UUID,
        passageId: UUID,
        existingCompletions: [PassageCompletion]
    ) -> Int {
        let passageCompletions = existingCompletions.filter {
            $0.userId == userId && $0.passageId == passageId
        }
        return passageCompletions.count + 1
    }
    
    // MARK: - Progress Updates
    
    /// Update user progress after a new completion
    static func updateProgress(
        currentProgress: UserProgress,
        newCompletion: PassageCompletion,
        allCompletions: [PassageCompletion]
    ) -> UserProgress {
        // CRITICAL FIX: Filter by userId AND level (not just userId)
        let levelCompletions = allCompletions.filter { 
            $0.userId == currentProgress.userId && $0.level == currentProgress.level
        }
        
        // Add passage to completed list if not already there
        var completedIds = currentProgress.completedPassageIds
        if !completedIds.contains(newCompletion.passageId) {
            completedIds.append(newCompletion.passageId)
        }
        
        // Calculate total attempts (all completions for this user in this level)
        let totalAttempts = levelCompletions.count
        
        // Calculate average score across all attempts in this level
        let allScores = levelCompletions.map { $0.score }
        let averageScore = allScores.isEmpty ? 0.0 : allScores.reduce(0.0, +) / Double(allScores.count)
        
        // Get best score in this level
        let bestScore = allScores.max() ?? 0.0
        
        // Latest score is from the new completion
        let latestScore = newCompletion.score
        
        return UserProgress(
            id: currentProgress.id,
            userId: currentProgress.userId,
            level: currentProgress.level,
            completedPassageIds: completedIds,
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            bestScore: bestScore,
            latestScore: latestScore,
            lastActivityAt: Date()
        )
    }
    
    // MARK: - Completion History
    
    /// Get all completions for a specific passage and user
    static func getCompletionHistory(
        userId: UUID,
        passageId: UUID,
        allCompletions: [PassageCompletion]
    ) -> [PassageCompletion] {
        allCompletions
            .filter { $0.userId == userId && $0.passageId == passageId }
            .sorted { $0.completedAt < $1.completedAt }  // Oldest first
    }
    
    /// Get the most recent completion for a passage
    static func getLatestCompletion(
        userId: UUID,
        passageId: UUID,
        allCompletions: [PassageCompletion]
    ) -> PassageCompletion? {
        getCompletionHistory(userId: userId, passageId: passageId, allCompletions: allCompletions).last
    }
    
    /// Check if a passage has been completed by a user
    static func isCompleted(
        userId: UUID,
        passageId: UUID,
        allCompletions: [PassageCompletion]
    ) -> Bool {
        allCompletions.contains { $0.userId == userId && $0.passageId == passageId }
    }
    
    // MARK: - Score Comparison
    
    /// Compare new score with previous attempts
    static func getScoreComparison(
        newScore: Double,
        previousCompletions: [PassageCompletion]
    ) -> ScoreComparison {
        // Sort by date to ensure we compare with the most recent previous attempt
        guard let previousScore = previousCompletions
            .sorted(by: { $0.completedAt < $1.completedAt })
            .last?.score else {
            return .firstAttempt
        }
        
        let difference = newScore - previousScore
        
        if difference > 0.01 {  // Improved by more than 1%
            return .improved(from: previousScore, to: newScore)
        } else if difference < -0.01 {  // Decreased by more than 1%
            return .decreased(from: previousScore, to: newScore)
        } else {
            return .same(previousScore)
        }
    }
    
    /// Enum representing score comparison result
    enum ScoreComparison {
        case firstAttempt
        case improved(from: Double, to: Double)
        case decreased(from: Double, to: Double)
        case same(Double)
        
        var message: String {
            switch self {
            case .firstAttempt:
                return "First attempt complete!"
            case .improved(let from, let to):
                let fromPercent = Int(from * 100)
                let toPercent = Int(to * 100)
                return "Improved from \(fromPercent)% to \(toPercent)%! 🎉"
            case .decreased(let from, let to):
                let fromPercent = Int(from * 100)
                let toPercent = Int(to * 100)
                return "Score: \(toPercent)% (previous: \(fromPercent)%)"
            case .same(let score):
                let percent = Int(score * 100)
                return "Score: \(percent)% (same as before)"
            }
        }
    }
}

