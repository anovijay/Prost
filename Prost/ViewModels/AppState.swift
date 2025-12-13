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
class AppState: ObservableObject {
    
    // MARK: - Published State
    
    @Published var currentUser: User
    @Published var completions: [PassageCompletion]
    @Published var userProgress: [UserProgress]
    
    // MARK: - Initialization
    
    init(
        currentUser: User = .sampleUser,
        completions: [PassageCompletion] = PassageCompletion.sampleCompletions,
        userProgress: [UserProgress] = UserProgress.sampleProgress
    ) {
        self.currentUser = currentUser
        self.completions = completions
        self.userProgress = userProgress
    }
    
    // MARK: - Completion Actions
    
    /// Add a new completion and update progress
    func addCompletion(_ completion: PassageCompletion, for passage: ReadingPassage) {
        // Add to completions list
        completions.append(completion)
        
        // Update progress for the relevant level
        if let index = userProgress.firstIndex(where: { $0.level == passage.level }) {
            let currentProgress = userProgress[index]
            
            // CompletionService.updateProgress now handles level filtering internally
            // Just pass all completions
            let updatedProgress = CompletionService.updateProgress(
                currentProgress: currentProgress,
                newCompletion: completion,
                allCompletions: completions
            )
            
            userProgress[index] = updatedProgress
        }
    }
    
    /// Get completion history for a specific passage
    func getCompletionHistory(for passageId: UUID) -> [PassageCompletion] {
        CompletionService.getCompletionHistory(
            userId: currentUser.id,
            passageId: passageId,
            allCompletions: completions
        )
    }
    
    /// Check if a passage is completed
    func isCompleted(_ passageId: UUID) -> Bool {
        CompletionService.isCompleted(
            userId: currentUser.id,
            passageId: passageId,
            allCompletions: completions
        )
    }
    
    /// Get the attempt number for the next completion
    func getNextAttemptNumber(for passageId: UUID) -> Int {
        CompletionService.calculateAttemptNumber(
            userId: currentUser.id,
            passageId: passageId,
            existingCompletions: completions
        )
    }
    
    /// Get progress for a specific level
    func getProgress(for level: String) -> UserProgress? {
        userProgress.first { $0.level == level }
    }
}

