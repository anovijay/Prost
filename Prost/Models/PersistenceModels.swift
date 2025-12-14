//
//  PersistenceModels.swift
//  Prost
//
//  SwiftData models for persistence
//

import Foundation
import SwiftData

// MARK: - User (Persisted)

@Model
final class DBUser {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var progress: [DBUserProgress]?
    
    init(id: UUID, name: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.email = email
        self.createdAt = createdAt
    }
}

// MARK: - UserProgress (Persisted)

@Model
final class DBUserProgress {
    @Attribute(.unique) var id: UUID
    var level: String
    var completedExamIds: [UUID]
    var totalAttempts: Int
    var averageScore: Double
    var bestScore: Double
    var latestScore: Double
    var isPassed: Bool
    var lastActivityAt: Date
    
    // Optional per-part scores
    var part1AverageScore: Double?
    var part2AverageScore: Double?
    var part3AverageScore: Double?
    
    var user: DBUser?
    
    init(
        id: UUID = UUID(),
        level: String,
        completedExamIds: [UUID] = [],
        totalAttempts: Int = 0,
        averageScore: Double = 0.0,
        bestScore: Double = 0.0,
        latestScore: Double = 0.0,
        isPassed: Bool = false,
        lastActivityAt: Date = Date(),
        part1AverageScore: Double? = nil,
        part2AverageScore: Double? = nil,
        part3AverageScore: Double? = nil
    ) {
        self.id = id
        self.level = level
        self.completedExamIds = completedExamIds
        self.totalAttempts = totalAttempts
        self.averageScore = averageScore
        self.bestScore = bestScore
        self.latestScore = latestScore
        self.isPassed = isPassed
        self.lastActivityAt = lastActivityAt
        self.part1AverageScore = part1AverageScore
        self.part2AverageScore = part2AverageScore
        self.part3AverageScore = part3AverageScore
    }
    
    // Convert to view model
    func toUserProgress(userId: UUID) -> UserProgress {
        UserProgress(
            id: id,
            userId: userId,
            level: level,
            completedPassageIds: completedExamIds,
            totalAttempts: totalAttempts,
            averageScore: averageScore,
            bestScore: bestScore,
            latestScore: latestScore,
            lastActivityAt: lastActivityAt
        )
    }
}

// MARK: - Reading Exam Models (Persisted)

@Model
final class DBReadingExam {
    @Attribute(.unique) var id: UUID
    var title: String
    var level: String
    var examType: String
    var duration: Int
    var totalQuestions: Int
    var tags: [String]
    
    @Relationship(deleteRule: .cascade, inverse: \DBReadingPart.exam)
    var parts: [DBReadingPart]?
    
    init(
        id: UUID = UUID(),
        title: String,
        level: String,
        examType: String,
        duration: Int,
        totalQuestions: Int,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.level = level
        self.examType = examType
        self.duration = duration
        self.totalQuestions = totalQuestions
        self.tags = tags
    }
}

@Model
final class DBReadingPart {
    @Attribute(.unique) var id: UUID
    var partNumber: Int
    var title: String
    var instructions: String
    var textType: String
    
    var exam: DBReadingExam?
    
    @Relationship(deleteRule: .cascade, inverse: \DBReadingText.part)
    var texts: [DBReadingText]?
    
    @Relationship(deleteRule: .cascade, inverse: \DBQuestion.part)
    var questions: [DBQuestion]?
    
    init(
        id: UUID = UUID(),
        partNumber: Int,
        title: String,
        instructions: String,
        textType: String
    ) {
        self.id = id
        self.partNumber = partNumber
        self.title = title
        self.instructions = instructions
        self.textType = textType
    }
}

@Model
final class DBReadingText {
    @Attribute(.unique) var id: UUID
    var title: String?
    var content: String
    var textNumber: Int?
    
    var part: DBReadingPart?
    
    init(
        id: UUID = UUID(),
        title: String? = nil,
        content: String,
        textNumber: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.textNumber = textNumber
    }
}

@Model
final class DBQuestion {
    @Attribute(.unique) var id: UUID
    var questionNumber: Int
    var prompt: String
    var type: String // "trueFalse", "binaryChoice", "multipleChoice"
    var correctOptionID: UUID
    
    var part: DBReadingPart?
    
    @Relationship(deleteRule: .cascade, inverse: \DBQuestionOption.question)
    var options: [DBQuestionOption]?
    
    init(
        id: UUID = UUID(),
        questionNumber: Int,
        prompt: String,
        type: String,
        correctOptionID: UUID
    ) {
        self.id = id
        self.questionNumber = questionNumber
        self.prompt = prompt
        self.type = type
        self.correctOptionID = correctOptionID
    }
}

@Model
final class DBQuestionOption {
    @Attribute(.unique) var id: UUID
    var text: String
    var value: String
    
    var question: DBQuestion?
    
    init(
        id: UUID = UUID(),
        text: String,
        value: String
    ) {
        self.id = id
        self.text = text
        self.value = value
    }
}

