//
//  ReadingModels.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

// MARK: - User

struct User: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let email: String
    let createdAt: Date
    
    init(id: UUID = UUID(), name: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - Reading Passage

struct ReadingPassage: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let level: String
    let text: String
    let questions: [ReadingQuestion]
    let tags: [String]  // For search filtering (e.g., ["travel", "daily-life", "food"])

    init(id: UUID = UUID(), title: String, level: String, text: String, questions: [ReadingQuestion], tags: [String] = []) {
        self.id = id
        self.title = title
        self.level = level
        self.text = text
        self.questions = questions
        self.tags = tags
    }
}

struct ReadingQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    let prompt: String
    let options: [ReadingOption]
    let correctOptionID: UUID

    init(id: UUID = UUID(), prompt: String, options: [ReadingOption], correctOptionID: UUID) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctOptionID = correctOptionID
    }

    func isCorrect(selectedOptionID: UUID?) -> Bool {
        selectedOptionID == correctOptionID
    }
}

struct ReadingOption: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

struct ReadingQuestionResult: Identifiable, Hashable {
    let id: UUID
    let question: ReadingQuestion
    let selectedOptionID: UUID?

    init(id: UUID = UUID(), question: ReadingQuestion, selectedOptionID: UUID?) {
        self.id = id
        self.question = question
        self.selectedOptionID = selectedOptionID
    }

    var isCorrect: Bool { question.isCorrect(selectedOptionID: selectedOptionID) }

    var selectedOptionText: String? {
        guard let selectedOptionID else { return nil }
        return question.options.first(where: { $0.id == selectedOptionID })?.text
    }

    var correctOptionText: String {
        question.options.first(where: { $0.id == question.correctOptionID })?.text ?? "—"
    }
}

// MARK: - Passage Completion

struct PassageCompletion: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let passageId: UUID
    let score: Double  // 0.0 to 1.0
    let completedAt: Date
    let attemptNumber: Int  // 1st attempt, 2nd attempt, etc.
    
    init(id: UUID = UUID(), 
         userId: UUID, 
         passageId: UUID, 
         score: Double, 
         completedAt: Date = Date(), 
         attemptNumber: Int) {
        self.id = id
        self.userId = userId
        self.passageId = passageId
        self.score = score
        self.completedAt = completedAt
        self.attemptNumber = attemptNumber
    }
    
    // Computed properties
    var scorePercentage: Int { Int(score * 100) }
    var isPerfect: Bool { score == 1.0 }
}

// MARK: - User Progress (Aggregated)

struct UserProgress: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let level: String  // A1, A2, B1, B2
    
    let completedPassageIds: [UUID]
    let totalAttempts: Int
    let averageScore: Double  // 0.0 to 1.0
    let bestScore: Double  // 0.0 to 1.0
    let latestScore: Double  // 0.0 to 1.0 (most recent attempt)
    let lastActivityAt: Date
    
    init(id: UUID = UUID(),
         userId: UUID,
         level: String,
         completedPassageIds: [UUID] = [],
         totalAttempts: Int = 0,
         averageScore: Double = 0.0,
         bestScore: Double = 0.0,
         latestScore: Double = 0.0,
         lastActivityAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.level = level
        self.completedPassageIds = completedPassageIds
        self.totalAttempts = totalAttempts
        self.averageScore = averageScore
        self.bestScore = bestScore
        self.latestScore = latestScore
        self.lastActivityAt = lastActivityAt
    }
    
    // Computed properties
    var completedCount: Int { completedPassageIds.count }
    var averageScorePercentage: Int { Int(averageScore * 100) }
    var bestScorePercentage: Int { Int(bestScore * 100) }
    var latestScorePercentage: Int { Int(latestScore * 100) }
}

// MARK: - Legacy (Deprecated - use UserProgress instead)

@available(*, deprecated, message: "Use UserProgress instead")
struct LevelProgress: Identifiable {
    let id = UUID()
    let level: String
    let passagesCompleted: Int
    let overallScore: Double
}
