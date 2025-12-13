//
//  ReadingSamples.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

extension ReadingPassage {
    static var sampleBerlinDay: ReadingPassage {
        let q1a = ReadingOption(text: "In Berlin")
        let q1b = ReadingOption(text: "In München")
        let q1c = ReadingOption(text: "In Hamburg")

        let q2a = ReadingOption(text: "Sie besucht ein Museum.")
        let q2b = ReadingOption(text: "Sie fährt nach Hause.")
        let q2c = ReadingOption(text: "Sie geht schwimmen.")

        let q3a = ReadingOption(text: "Am Morgen")
        let q3b = ReadingOption(text: "Am Nachmittag")
        let q3c = ReadingOption(text: "Am Abend")

        let q1 = ReadingQuestion(
            prompt: "Wo ist Lena heute?",
            options: [q1a, q1b, q1c],
            correctOptionID: q1a.id
        )

        let q2 = ReadingQuestion(
            prompt: "Was macht Lena nach dem Mittagessen?",
            options: [q2a, q2b, q2c],
            correctOptionID: q2a.id
        )

        let q3 = ReadingQuestion(
            prompt: "Wann trifft Lena ihre Freundin?",
            options: [q3a, q3b, q3c],
            correctOptionID: q3c.id
        )

        return ReadingPassage(
            title: "Ein Tag in Berlin",
            level: "A2",
            text: """
            Lena ist heute in Berlin. Am Morgen geht sie in ein Café und trinkt einen Kaffee. Danach macht sie einen Spaziergang im Park.
            Zum Mittagessen isst sie eine Suppe und ein Stück Brot. Nach dem Essen besucht sie ein Museum und sieht viele interessante Bilder.
            Am Abend trifft sie eine Freundin in einem kleinen Restaurant. Sie sprechen lange und lachen viel. Spät am Abend fährt Lena müde,
            aber glücklich ins Hotel zurück.
            """,
            questions: [q1, q2, q3],
            tags: ["travel", "daily-life", "food", "culture"]
        )
    }
}

// MARK: - User Samples

extension User {
    static var sampleUser: User {
        User(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Demo User",
            email: "demo@prost.app",
            createdAt: Date(timeIntervalSinceNow: -30 * 24 * 60 * 60) // 30 days ago
        )
    }
}

// MARK: - Passage Completion Samples

extension PassageCompletion {
    static var sampleCompletions: [PassageCompletion] {
        let userId = User.sampleUser.id
        let passageId = ReadingPassage.sampleBerlinDay.id
        
        return [
            // First attempt - not perfect
            PassageCompletion(
                userId: userId,
                passageId: passageId,
                score: 0.67,
                completedAt: Date(timeIntervalSinceNow: -5 * 24 * 60 * 60), // 5 days ago
                attemptNumber: 1
            ),
            // Second attempt - improved
            PassageCompletion(
                userId: userId,
                passageId: passageId,
                score: 1.0,
                completedAt: Date(timeIntervalSinceNow: -2 * 24 * 60 * 60), // 2 days ago
                attemptNumber: 2
            )
        ]
    }
}

// MARK: - User Progress Samples

extension UserProgress {
    static var sampleProgress: [UserProgress] {
        let userId = User.sampleUser.id
        let passageId = ReadingPassage.sampleBerlinDay.id
        
        return [
            // A1 - Completed level
            UserProgress(
                userId: userId,
                level: "A1",
                completedPassageIds: Array(repeating: UUID(), count: 10),
                totalAttempts: 15,
                averageScore: 0.65,
                bestScore: 0.90,
                latestScore: 0.70,
                lastActivityAt: Date(timeIntervalSinceNow: -10 * 24 * 60 * 60) // 10 days ago
            ),
            // A2 - Current level (includes sample passage)
            UserProgress(
                userId: userId,
                level: "A2",
                completedPassageIds: [passageId] + Array(repeating: UUID(), count: 4),
                totalAttempts: 7,
                averageScore: 0.58,
                bestScore: 1.0,
                latestScore: 1.0,
                lastActivityAt: Date(timeIntervalSinceNow: -2 * 24 * 60 * 60) // 2 days ago
            ),
            // B1 - Not started
            UserProgress(
                userId: userId,
                level: "B1",
                completedPassageIds: [],
                totalAttempts: 0,
                averageScore: 0.0,
                bestScore: 0.0,
                latestScore: 0.0,
                lastActivityAt: Date()
            ),
            // B2 - Not started
            UserProgress(
                userId: userId,
                level: "B2",
                completedPassageIds: [],
                totalAttempts: 0,
                averageScore: 0.0,
                bestScore: 0.0,
                latestScore: 0.0,
                lastActivityAt: Date()
            )
        ]
    }
}

// MARK: - Legacy (Deprecated)

@available(*, deprecated, message: "Use UserProgress.sampleProgress instead")
extension LevelProgress {
    static var sampleLevels: [LevelProgress] {
        [
            LevelProgress(level: "A1", passagesCompleted: 10, overallScore: 0.65),
            LevelProgress(level: "A2", passagesCompleted: 5, overallScore: 0.58),
            LevelProgress(level: "B1", passagesCompleted: 0, overallScore: 0.0),
            LevelProgress(level: "B2", passagesCompleted: 0, overallScore: 0.0),
        ]
    }
}

