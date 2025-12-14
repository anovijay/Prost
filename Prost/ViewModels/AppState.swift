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
    
    // Goethe A1 specific
    @Published var goetheCompletions: [GoetheA1ExamCompletion] = []
    @Published var goetheA1Progress: GoetheA1UserProgress
    
    // MARK: - Initialization
    
    init(
        currentUser: User,
        completions: [PassageCompletion],
        userProgress: [UserProgress],
        goetheCompletions: [GoetheA1ExamCompletion] = [],
        goetheA1Progress: GoetheA1UserProgress? = nil
    ) {
        self.currentUser = currentUser
        self.completions = completions
        self.userProgress = userProgress
        self.goetheCompletions = goetheCompletions
        self.goetheA1Progress = goetheA1Progress ?? GoetheA1UserProgress.notStartedProgress
    }
    
    // Convenience initializer with sample data
    convenience init() {
        self.init(
            currentUser: User.sampleUser,
            completions: PassageCompletion.sampleCompletions,
            userProgress: UserProgress.sampleProgress,
            goetheCompletions: [],
            goetheA1Progress: GoetheA1UserProgress.notStartedProgress
        )
    }
    
    // MARK: - Goethe A1 Methods
    
    /// Add a Goethe A1 exam completion
    func addGoetheCompletion(_ completion: GoetheA1ExamCompletion, result: GoetheA1ExamResult) {
        goetheCompletions.append(completion)
        updateGoetheProgress(with: completion, result: result)
    }
    
    /// Get completion history for a Goethe exam
    func goetheCompletionHistory(for examId: UUID) -> [GoetheA1ExamCompletion] {
        goetheCompletions
            .filter { $0.examId == examId && $0.userId == currentUser.id }
            .sorted { $0.completedAt < $1.completedAt }
    }
    
    /// Get next attempt number for a Goethe exam
    func getNextGoetheAttemptNumber(for examId: UUID) -> Int {
        let existingAttempts = goetheCompletions.filter {
            $0.examId == examId && $0.userId == currentUser.id
        }
        return existingAttempts.count + 1
    }
    
    /// Update Goethe A1 progress after completion
    private func updateGoetheProgress(with completion: GoetheA1ExamCompletion, result: GoetheA1ExamResult) {
        let userId = currentUser.id
        
        // Get all completions for this user
        let userCompletions = goetheCompletions.filter { $0.userId == userId }
        
        // Calculate aggregated stats
        let completedExamIds = Set(userCompletions.map { $0.examId })
        let totalAttempts = userCompletions.count
        let averageScore = userCompletions.isEmpty ? 0.0 : userCompletions.map { $0.score }.reduce(0, +) / Double(userCompletions.count)
        let bestScore = userCompletions.map { $0.score }.max() ?? 0.0
        let isPassed = userCompletions.contains { $0.isPassed }
        
        // Calculate per-part averages (from all attempts)
        var part1Scores: [Double] = []
        var part2Scores: [Double] = []
        var part3Scores: [Double] = []
        
        // For now, just use the current result's part scores
        // TODO: Store per-part scores in completion for accurate history
        if let part1 = result.part1Result {
            part1Scores.append(part1.score)
        }
        if let part2 = result.part2Result {
            part2Scores.append(part2.score)
        }
        if let part3 = result.part3Result {
            part3Scores.append(part3.score)
        }
        
        let part1Avg = part1Scores.isEmpty ? 0.0 : part1Scores.reduce(0, +) / Double(part1Scores.count)
        let part2Avg = part2Scores.isEmpty ? 0.0 : part2Scores.reduce(0, +) / Double(part2Scores.count)
        let part3Avg = part3Scores.isEmpty ? 0.0 : part3Scores.reduce(0, +) / Double(part3Scores.count)
        
        // Create updated progress
        goetheA1Progress = GoetheA1UserProgress(
            userId: userId,
            level: "A1",
            completedExamIds: Array(completedExamIds),
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            bestScore: bestScore,
            latestScore: completion.score,
            isPassed: isPassed,
            part1AverageScore: part1Avg,
            part2AverageScore: part2Avg,
            part3AverageScore: part3Avg,
            lastActivityAt: completion.completedAt
        )
    }
    
}

