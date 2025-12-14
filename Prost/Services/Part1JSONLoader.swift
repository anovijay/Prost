//
//  Part1JSONLoader.swift
//  Prost
//
//  Load A1 Part 1 practices from reading.json and transform to ReadingPassage models
//

import Foundation

// MARK: - Seed JSON Format Models

/// These models match the structure of seed_data/reading.json
private struct SeedPart1Data: Codable {
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
struct Part1JSONLoader {
    
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
    
    /// Load A1 Part 1 practices from reading.json
    static func loadPart1Practices() throws -> [ReadingPassage] {
        let part1Data = try loadSeedData(filename: "reading")
        let practices = transformToPractices(part1Data)
        
        guard !practices.isEmpty else {
            throw LoaderError.emptyData
        }
        
        return practices
    }
    
    // MARK: - Private Methods
    
    /// Load seed data file from bundle
    private static func loadSeedData(filename: String) throws -> SeedPart1Data {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw LoaderError.fileNotFound("\(filename).json")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(SeedPart1Data.self, from: data)
        } catch let error as DecodingError {
            throw LoaderError.decodingError(error)
        } catch {
            throw LoaderError.invalidJSON
        }
    }
    
    /// Transform seed format into [ReadingPassage]
    private static func transformToPractices(_ seedData: SeedPart1Data) -> [ReadingPassage] {
        var practices: [ReadingPassage] = []
        
        for (index, test) in seedData.tests.enumerated() {
            // Create Richtig/Falsch options for each statement
            var questions: [ReadingQuestion] = []
            
            for statement in test.statements {
                let richtigOption = ReadingOption(text: "Richtig")
                let falschOption = ReadingOption(text: "Falsch")
                
                let correctOptionID = statement.answer == "R" ? richtigOption.id : falschOption.id
                
                let question = ReadingQuestion(
                    prompt: statement.statement,
                    options: [richtigOption, falschOption],
                    correctOptionID: correctOptionID
                )
                
                questions.append(question)
            }
            
            // Create practice passage
            let practice = ReadingPassage(
                title: "Practice \(index + 1): \(getPracticeTitle(from: test.text))",
                level: "A1",
                text: test.text,
                questions: questions,
                tags: ["part1", "informal-text", "richtig-falsch"]
            )
            
            practices.append(practice)
        }
        
        return practices
    }
    
    /// Extract a short title from the text content
    private static func getPracticeTitle(from text: String) -> String {
        // Extract first line or first few words for title
        let lines = text.split(separator: "\n")
        if let firstLine = lines.first {
            let words = firstLine.split(separator: " ").prefix(4)
            let title = words.joined(separator: " ")
            return title.count > 30 ? String(title.prefix(30)) + "..." : title
        }
        return "Informal Text"
    }
}

