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
            questions: [q1, q2, q3]
        )
    }
}

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

