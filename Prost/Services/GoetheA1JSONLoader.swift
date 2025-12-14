//
//  GoetheA1JSONLoader.swift
//  Prost
//
//  Service to load and transform seed data JSON into GoetheA1ReadingExam models
//

import Foundation

// MARK: - Seed JSON Format Models

/// These models match the structure of seed_data/reading.json
private struct SeedExamData: Codable {
    let exam: String
    let section: String
    let part: Int
    let instructions_de: String
    let tests: [SeedTest]
}

private struct SeedTest: Codable {
    let id: String
    let text: String
    let statements: [SeedStatement]
}

private struct SeedStatement: Codable {
    let id: Int
    let statement: String
    let answer: String  // "R" or "F"
}

// MARK: - JSON Loader Service

@MainActor
struct GoetheA1JSONLoader {
    
    enum LoaderError: Error, LocalizedError {
        case fileNotFound(String)
        case invalidJSON
        case decodingError(Error)
        case missingParts
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "JSON file not found: \(filename)"
            case .invalidJSON:
                return "Invalid JSON format"
            case .decodingError(let error):
                return "Failed to decode JSON: \(error.localizedDescription)"
            case .missingParts:
                return "Missing required exam parts"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Load all Goethe A1 exams from bundle resources
    static func loadGoetheA1Exams() throws -> [GoetheA1ReadingExam] {
        // For now, we have reading.json (Part 1) and reading2.json
        // In a complete implementation, we'd combine Part 1, 2, 3 into one exam
        
        let part1Data = try loadSeedData(filename: "reading")
        
        // Transform single part into exam (for now)
        // TODO: Load Part 2 and Part 3 when available
        let exam = try transformToExam(parts: [part1Data], examNumber: 1)
        
        return [exam]
    }
    
    /// Load a single seed data file from bundle
    private static func loadSeedData(filename: String) throws -> SeedExamData {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound("\(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(SeedExamData.self, from: data)
        } catch let error as DecodingError {
            throw LoaderError.decodingError(error)
        } catch {
            throw LoaderError.invalidJSON
        }
    }
    
    // MARK: - Transformation
    
    /// Transform seed format into GoetheA1ReadingExam
    private static func transformToExam(
        parts: [SeedExamData],
        examNumber: Int
    ) throws -> GoetheA1ReadingExam {
        
        guard !parts.isEmpty else {
            throw LoaderError.missingParts
        }
        
        var transformedParts: [GoetheA1ReadingPart] = []
        var questionNumber = 1  // Questions numbered 1-15 across all parts
        
        for partData in parts {
            let part = transformPart(
                partData,
                startingQuestionNumber: &questionNumber
            )
            transformedParts.append(part)
        }
        
        let totalQuestions = transformedParts.reduce(0) { $0 + $1.questionCount }
        
        return GoetheA1ReadingExam(
            title: "Goethe A1 Reading Practice \(examNumber)",
            level: "A1",
            examType: "goethe_a1_reading",
            duration: 25,
            totalQuestions: totalQuestions,
            parts: transformedParts,
            tags: ["goethe", "a1", "practice", "reading"]
        )
    }
    
    /// Transform a single part
    private static func transformPart(
        _ seedData: SeedExamData,
        startingQuestionNumber: inout Int
    ) -> GoetheA1ReadingPart {
        
        // Transform texts
        let texts = seedData.tests.map { test in
            GoetheA1Text(
                title: nil,  // Seed data doesn't have titles
                content: test.text,
                textNumber: nil
            )
        }
        
        // Transform questions (statements → questions)
        var questions: [GoetheA1Question] = []
        
        for test in seedData.tests {
            for statement in test.statements {
                let question = transformQuestion(
                    statement: statement,
                    questionNumber: startingQuestionNumber
                )
                questions.append(question)
                startingQuestionNumber += 1
            }
        }
        
        // Determine part title based on part number
        let partTitle = getPartTitle(for: seedData.part)
        let textType = getTextType(for: seedData.part)
        
        return GoetheA1ReadingPart(
            partNumber: seedData.part,
            title: partTitle,
            instructions: seedData.instructions_de,
            textType: textType,
            texts: texts,
            questions: questions
        )
    }
    
    /// Transform a single statement into a question
    private static func transformQuestion(
        statement: SeedStatement,
        questionNumber: Int
    ) -> GoetheA1Question {
        
        // Create Richtig/Falsch options
        let richtigOption = GoetheA1Option(
            text: "Richtig",
            value: "True"
        )
        let falschOption = GoetheA1Option(
            text: "Falsch",
            value: "False"
        )
        
        // Determine correct option based on answer "R" or "F"
        let correctOptionID = statement.answer == "R" ? richtigOption.id : falschOption.id
        
        return GoetheA1Question(
            questionNumber: questionNumber,
            prompt: statement.statement,
            type: .trueFalse,
            options: [richtigOption, falschOption],
            correctOptionID: correctOptionID
        )
    }
    
    // MARK: - Helpers
    
    private static func getPartTitle(for partNumber: Int) -> String {
        switch partNumber {
        case 1:
            return "Part 1: Short Informal Texts"
        case 2:
            return "Part 2: Situation-Based Texts"
        case 3:
            return "Part 3: Signs and Notices"
        default:
            return "Part \(partNumber)"
        }
    }
    
    private static func getTextType(for partNumber: Int) -> String {
        switch partNumber {
        case 1:
            return "informal_texts"
        case 2:
            return "situation_based"
        case 3:
            return "notices_signs"
        default:
            return "other"
        }
    }
}

