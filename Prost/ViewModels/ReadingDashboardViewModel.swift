//
//  ReadingDashboardViewModel.swift
//  Prost
//
//  Minimal ViewModel for ReadingDashboardView
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class ReadingDashboardViewModel {
    
    private let modelContext: ModelContext
    private var currentUser: DBUser
    
    var userProgress: [UserProgress] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Get or create user
        self.currentUser = Self.fetchOrCreateUser(context: modelContext)
        
        // Load progress
        loadProgress()
    }
    
    // MARK: - Data Loading
    
    func loadProgress() {
        let descriptor = FetchDescriptor<DBUserProgress>(
            sortBy: [SortDescriptor(\.level)]
        )
        
        if let dbProgress = try? modelContext.fetch(descriptor) {
            // Filter by current user in memory
            let userProgressList = dbProgress
                .filter { $0.user?.id == currentUser.id }
                .map { $0.toUserProgress(userId: currentUser.id) }
            userProgress = userProgressList
        }
        
        // If no progress exists, seed initial data
        if userProgress.isEmpty {
            seedInitialProgress()
        }
    }
    
    // MARK: - Seed Data
    
    private func seedInitialProgress() {
        let levels = ["A1", "A2", "B1", "B2"]
        
        for level in levels {
            let dbProgress = DBUserProgress(
                level: level,
                completedExamIds: [],
                totalAttempts: 0,
                averageScore: 0.0,
                bestScore: 0.0,
                latestScore: 0.0,
                isPassed: false
            )
            dbProgress.user = currentUser
            modelContext.insert(dbProgress)
        }
        
        try? modelContext.save()
        loadProgress()
    }
    
    // MARK: - User Management
    
    private static func fetchOrCreateUser(context: ModelContext) -> DBUser {
        let sampleUserId = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        let descriptor = FetchDescriptor<DBUser>(
            predicate: #Predicate { $0.id == sampleUserId }
        )
        
        if let existingUser = try? context.fetch(descriptor).first {
            return existingUser
        }
        
        // Create new user
        let newUser = DBUser(
            id: sampleUserId,
            name: "Demo User",
            email: "demo@prost.app"
        )
        context.insert(newUser)
        try? context.save()
        return newUser
    }
}

