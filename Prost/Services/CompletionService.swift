//
//  CompletionService.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

// NOTE: This file now houses the reading completion helpers directly on AppState to
// avoid an extra service layer. The type name remains for Xcode project compatibility.
extension AppState {

    // MARK: - Completion Actions

    /// Record a completion for a passage and update progress.
    @discardableResult
    func recordCompletion(for passage: ReadingPassage, score: Double) -> PassageCompletion {
        let completion = PassageCompletion(
            userId: currentUser.id,
            passageId: passage.id,
            level: passage.level,
            score: score,
            attemptNumber: nextAttemptNumber(for: passage.id)
        )

        completions.append(completion)
        updateProgress(for: passage, with: completion)
        return completion
    }

    /// Get completion history for a specific passage.
    func completionHistory(for passageId: UUID) -> [PassageCompletion] {
        passageCompletions(for: passageId)
            .sorted { $0.completedAt < $1.completedAt }
    }

    /// Check if a passage is completed.
    func isCompleted(_ passageId: UUID) -> Bool {
        !passageCompletions(for: passageId).isEmpty
    }

    /// Get the attempt number for the next completion.
    func nextAttemptNumber(for passageId: UUID) -> Int {
        passageCompletions(for: passageId).count + 1
    }

    /// Get progress for a specific level.
    func progress(for level: String) -> UserProgress? {
        userProgress.first { $0.level == level }
    }

    /// Compare a new score to the most recent attempt for a passage.
    func compareScore(for passageId: UUID, newScore: Double) -> ScoreComparison {
        guard let previousScore = completionHistory(for: passageId).last?.score else {
            return .firstAttempt
        }

        let difference = newScore - previousScore

        if difference > 0.01 {
            return .improved(from: previousScore, to: newScore)
        } else if difference < -0.01 {
            return .decreased(from: previousScore, to: newScore)
        } else {
            return .same(previousScore)
        }
    }

    /// Enum representing score comparison results.
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

// MARK: - Private Helpers

private extension AppState {
    func passageCompletions(for passageId: UUID) -> [PassageCompletion] {
        completions.filter { $0.userId == currentUser.id && $0.passageId == passageId }
    }

    func levelCompletions(for level: String) -> [PassageCompletion] {
        completions.filter { $0.userId == currentUser.id && $0.level == level }
    }

    func updateProgress(for passage: ReadingPassage, with completion: PassageCompletion) {
        guard let index = userProgress.firstIndex(where: { $0.level == passage.level }) else { return }

        let currentProgress = userProgress[index]
        let levelCompletions = levelCompletions(for: passage.level)

        var completedIds = currentProgress.completedPassageIds
        if !completedIds.contains(completion.passageId) {
            completedIds.append(completion.passageId)
        }

        let totalAttempts = levelCompletions.count
        let allScores = levelCompletions.map { $0.score }
        let averageScore = allScores.isEmpty ? 0.0 : allScores.reduce(0.0, +) / Double(allScores.count)
        let bestScore = allScores.max() ?? 0.0

        userProgress[index] = UserProgress(
            id: currentProgress.id,
            userId: currentProgress.userId,
            level: currentProgress.level,
            completedPassageIds: completedIds,
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            bestScore: bestScore,
            latestScore: completion.score,
            lastActivityAt: Date()
        )
    }
}
