//
//  GoetheA1ReadingModels.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

// MARK: - Question Types

/// Enum representing different question types in Goethe A1 Reading
enum GoetheQuestionType: String, Codable, Hashable {
    case trueFalse = "True/False"           // Richtig/Falsch (Parts 1 & 3)
    case binaryChoice = "A/B Choice"        // Select A or B (Part 2)
    case multipleChoice = "Multiple Choice" // Future: for other formats
}

// MARK: - Goethe A1 Question

/// A question in the Goethe A1 Reading exam
struct GoetheA1Question: Identifiable, Codable, Hashable {
    let id: UUID
    let questionNumber: Int           // 1-15 across entire exam
    let prompt: String                // The question or statement
    let type: GoetheQuestionType
    let options: [GoetheA1Option]     // 2 options for True/False or A/B
    let correctOptionID: UUID
    
    init(
        id: UUID = UUID(),
        questionNumber: Int,
        prompt: String,
        type: GoetheQuestionType,
        options: [GoetheA1Option],
        correctOptionID: UUID
    ) {
        self.id = id
        self.questionNumber = questionNumber
        self.prompt = prompt
        self.type = type
        self.options = options
        self.correctOptionID = correctOptionID
    }
    
    // Computed property
    var correctOption: GoetheA1Option? {
        options.first { $0.id == correctOptionID }
    }
}

// MARK: - Goethe A1 Option

/// An answer option for a Goethe A1 question
struct GoetheA1Option: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String  // e.g., "Richtig", "Falsch", "A", "B"
    let value: String // For display: "True", "False", "Option A", "Option B"
    
    init(id: UUID = UUID(), text: String, value: String) {
        self.id = id
        self.text = text
        self.value = value
    }
}

// MARK: - Goethe A1 Reading Part

/// One part of the Goethe A1 Reading exam (3 parts total)
struct GoetheA1ReadingPart: Identifiable, Codable, Hashable {
    let id: UUID
    let partNumber: Int              // 1, 2, or 3
    let title: String                // e.g., "Part 1: Short Informal Texts"
    let instructions: String         // Instructions for this part
    let textType: String             // "informal_texts", "situation_based", "notices_signs"
    let texts: [GoetheA1Text]        // One or more texts for this part
    let questions: [GoetheA1Question] // ~5 questions per part
    
    init(
        id: UUID = UUID(),
        partNumber: Int,
        title: String,
        instructions: String,
        textType: String,
        texts: [GoetheA1Text],
        questions: [GoetheA1Question]
    ) {
        self.id = id
        self.partNumber = partNumber
        self.title = title
        self.instructions = instructions
        self.textType = textType
        self.texts = texts
        self.questions = questions
    }
    
    // Computed properties
    var questionCount: Int { questions.count }
    var questionRange: String {
        guard let first = questions.first?.questionNumber,
              let last = questions.last?.questionNumber else {
            return ""
        }
        return "Questions \(first)-\(last)"
    }
}

// MARK: - Goethe A1 Text

/// A text snippet in a Goethe A1 Reading part
struct GoetheA1Text: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String?               // Optional title
    let content: String              // The actual text
    let textNumber: Int?             // Optional: Text 1, Text 2, etc. (for Part 2)
    
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

// MARK: - Goethe A1 Reading Exam

/// Complete Goethe A1 Reading exam with all 3 parts
struct GoetheA1ReadingExam: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String                // e.g., "Goethe A1 Reading Practice 1"
    let level: String                // "A1"
    let examType: String             // "goethe_a1_reading"
    let duration: Int                // 25 minutes
    let totalQuestions: Int          // ~15
    let parts: [GoetheA1ReadingPart] // Always 3 parts
    let tags: [String]               // For search filtering
    
    init(
        id: UUID = UUID(),
        title: String,
        level: String = "A1",
        examType: String = "goethe_a1_reading",
        duration: Int = 25,
        totalQuestions: Int,
        parts: [GoetheA1ReadingPart],
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.level = level
        self.examType = examType
        self.duration = duration
        self.totalQuestions = totalQuestions
        self.parts = parts
        self.tags = tags
    }
    
    // Computed properties
    var allQuestions: [GoetheA1Question] {
        parts.flatMap { $0.questions }
    }
    
    var part1: GoetheA1ReadingPart? {
        parts.first { $0.partNumber == 1 }
    }
    
    var part2: GoetheA1ReadingPart? {
        parts.first { $0.partNumber == 2 }
    }
    
    var part3: GoetheA1ReadingPart? {
        parts.first { $0.partNumber == 3 }
    }
}

// MARK: - Goethe A1 Result Models

/// Result for a single question
struct GoetheA1QuestionResult: Identifiable, Codable, Hashable {
    let id: UUID
    let question: GoetheA1Question
    let selectedOptionID: UUID?
    
    init(
        id: UUID = UUID(),
        question: GoetheA1Question,
        selectedOptionID: UUID?
    ) {
        self.id = id
        self.question = question
        self.selectedOptionID = selectedOptionID
    }
    
    // Computed properties
    var isCorrect: Bool {
        selectedOptionID == question.correctOptionID
    }
    
    var selectedOption: GoetheA1Option? {
        guard let selectedID = selectedOptionID else { return nil }
        return question.options.first { $0.id == selectedID }
    }
    
    var selectedOptionText: String? {
        selectedOption?.text
    }
    
    var correctOption: GoetheA1Option? {
        question.correctOption
    }
    
    var correctOptionText: String {
        correctOption?.text ?? "Unknown"
    }
}

/// Result for a complete part
struct GoetheA1PartResult: Identifiable, Codable, Hashable {
    let id: UUID
    let partNumber: Int
    let questionResults: [GoetheA1QuestionResult]
    
    init(
        id: UUID = UUID(),
        partNumber: Int,
        questionResults: [GoetheA1QuestionResult]
    ) {
        self.id = id
        self.partNumber = partNumber
        self.questionResults = questionResults
    }
    
    // Computed properties
    var correctCount: Int {
        questionResults.filter { $0.isCorrect }.count
    }
    
    var totalCount: Int {
        questionResults.count
    }
    
    var score: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(totalCount)
    }
    
    var scorePercentage: Int {
        Int(score * 100)
    }
}

/// Complete exam result
struct GoetheA1ExamResult: Identifiable, Codable, Hashable {
    let id: UUID
    let examId: UUID
    let partResults: [GoetheA1PartResult]
    let completedAt: Date
    
    init(
        id: UUID = UUID(),
        examId: UUID,
        partResults: [GoetheA1PartResult],
        completedAt: Date = Date()
    ) {
        self.id = id
        self.examId = examId
        self.partResults = partResults
        self.completedAt = completedAt
    }
    
    // Computed properties
    var allQuestionResults: [GoetheA1QuestionResult] {
        partResults.flatMap { $0.questionResults }
    }
    
    var correctCount: Int {
        allQuestionResults.filter { $0.isCorrect }.count
    }
    
    var totalCount: Int {
        allQuestionResults.count
    }
    
    var overallScore: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(totalCount)
    }
    
    var overallScorePercentage: Int {
        Int(overallScore * 100)
    }
    
    var isPassed: Bool {
        // Goethe A1: Typically need 60% to pass
        overallScorePercentage >= 60
    }
    
    var part1Result: GoetheA1PartResult? {
        partResults.first { $0.partNumber == 1 }
    }
    
    var part2Result: GoetheA1PartResult? {
        partResults.first { $0.partNumber == 2 }
    }
    
    var part3Result: GoetheA1PartResult? {
        partResults.first { $0.partNumber == 3 }
    }
}

// MARK: - Goethe A1 Completion (for tracking)

/// Completion record for Goethe A1 exam (similar to PassageCompletion)
struct GoetheA1ExamCompletion: Identifiable, Codable, Hashable {
    let id: UUID
    let userId: UUID
    let examId: UUID
    let level: String              // "A1"
    let score: Double              // 0.0 to 1.0
    let isPassed: Bool             // Based on score >= 0.6
    let completedAt: Date
    let attemptNumber: Int
    let timeSpent: Int?            // Optional: seconds spent
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        examId: UUID,
        level: String,
        score: Double,
        isPassed: Bool,
        completedAt: Date = Date(),
        attemptNumber: Int,
        timeSpent: Int? = nil
    ) {
        self.id = id
        self.userId = userId
        self.examId = examId
        self.level = level
        self.score = min(max(score, 0.0), 1.0) // Clamp to 0.0-1.0
        self.isPassed = isPassed
        self.completedAt = completedAt
        self.attemptNumber = max(attemptNumber, 1) // Minimum 1
        self.timeSpent = timeSpent
    }
    
    // Computed properties
    var scorePercentage: Int { Int(score * 100) }
    var isPerfect: Bool { score == 1.0 }
    var timeSpentFormatted: String? {
        guard let seconds = timeSpent else { return nil }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes):\(String(format: "%02d", remainingSeconds))"
    }
}

