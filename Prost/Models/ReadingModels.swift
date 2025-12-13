//
//  ReadingModels.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

struct ReadingPassage: Identifiable, Hashable {
    let id: UUID
    let title: String
    let level: String
    let text: String
    let questions: [ReadingQuestion]

    init(id: UUID = UUID(), title: String, level: String, text: String, questions: [ReadingQuestion]) {
        self.id = id
        self.title = title
        self.level = level
        self.text = text
        self.questions = questions
    }
}

struct ReadingQuestion: Identifiable, Hashable {
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

struct ReadingOption: Identifiable, Hashable {
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

struct LevelProgress: Identifiable {
    let id = UUID()
    let level: String
    let passagesCompleted: Int
    let overallScore: Double
}
