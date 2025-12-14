//
//  Part2JSONLoader.swift
//  Prost
//
//  Load A1 Part 2 practices from reading-part2.json and transform to ReadingPassage models
//  Part 2: Situation-based A/B choice questions
//

import Foundation

// MARK: - Seed JSON Format Models

/// These models match the structure of seed_data/reading-part2.json
private struct SeedPart2Data: Codable {
    let exam: String
    let section: String
    let difficulty: String
    let questions: [SeedPart2Question]
}

private struct SeedPart2Question: Codable {
    let id: Int
    let situation: String
    let textA: String
    let textB: String
    let answer: String  // "A" or "B"
    let explanation: String
    let tags: [String]?
}

// MARK: - JSON Loader Service

@MainActor
struct Part2JSONLoader {
    
    enum LoaderError: Error, LocalizedError {
        case fileNotFound(String)
        case invalidJSON
        case decodingError(Error)
        case emptyData
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "JSON file not found: \(filename)"
            case .invalidJSON:
                return "Invalid JSON format"
            case .decodingError(let error):
                return "Failed to decode JSON: \(error.localizedDescription)"
            case .emptyData:
                return "No practices found in JSON"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Load A1 Part 2 practices from reading-part2.json
    static func loadPart2Practices() throws -> [ReadingPassage] {
        let part2Data = try loadSeedData(filename: "reading-part2")
        let practices = transformToPractices(part2Data)
        
        guard !practices.isEmpty else {
            throw LoaderError.emptyData
        }
        
        return practices
    }
    
    // MARK: - Private Methods
    
    /// Load seed data file from bundle
    private static func loadSeedData(filename: String) throws -> SeedPart2Data {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound("\(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(SeedPart2Data.self, from: data)
        } catch let error as DecodingError {
            throw LoaderError.decodingError(error)
        } catch {
            throw LoaderError.invalidJSON
        }
    }
    
    /// Transform seed format into [ReadingPassage]
    /// Each question becomes a practice with situation as text and A/B as options
    private static func transformToPractices(_ seedData: SeedPart2Data) -> [ReadingPassage] {
        var practices: [ReadingPassage] = []
        
        for seedQuestion in seedData.questions {
            // Create A/B options
            let optionA = ReadingOption(text: "Text A")
            let optionB = ReadingOption(text: "Text B")
            
            let correctOptionID = seedQuestion.answer == "A" ? optionA.id : optionB.id
            
            // Create the question with the situation as prompt
            // Store textA and textB in the prompt for display
            let fullPrompt = """
            \(seedQuestion.situation)
            
            Text A:
            \(seedQuestion.textA)
            
            Text B:
            \(seedQuestion.textB)
            """
            
            let question = ReadingQuestion(
                prompt: fullPrompt,
                options: [optionA, optionB],
                correctOptionID: correctOptionID
            )
            
            // Create practice passage
            // For Part 2, each question is its own practice
            let practice = ReadingPassage(
                title: "Practice \(seedQuestion.id): Situation Choice",
                level: "A1",
                text: seedQuestion.situation,  // Just the situation as main text
                questions: [question],  // Single question per practice
                tags: (seedQuestion.tags ?? []) + ["part2", "situation", "a-b-choice"]
            )
            
            practices.append(practice)
        }
        
        return practices
    }
}

