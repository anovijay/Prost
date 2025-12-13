//
//  GoetheA1Samples.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

// MARK: - Sample Options

extension GoetheA1Option {
    // True/False options (for Parts 1 & 3)
    static var richtig: GoetheA1Option {
        GoetheA1Option(text: "Richtig", value: "True")
    }
    
    static var falsch: GoetheA1Option {
        GoetheA1Option(text: "Falsch", value: "False")
    }
    
    // A/B options (for Part 2)
    static func optionA(_ description: String) -> GoetheA1Option {
        GoetheA1Option(text: "A", value: description)
    }
    
    static func optionB(_ description: String) -> GoetheA1Option {
        GoetheA1Option(text: "B", value: description)
    }
}

// MARK: - Sample Exam

extension GoetheA1ReadingExam {
    /// Complete sample Goethe A1 Reading exam
    static var sampleExam1: GoetheA1ReadingExam {
        // PART 1: Short Informal Texts (True/False)
        let part1Text = GoetheA1Text(
            title: "E-Mail von Anna",
            content: """
            Hallo Lisa,
            
            wie geht es dir? Ich bin jetzt in Berlin. Die Stadt ist sehr groß und interessant!
            Am Montag gehe ich ins Museum. Am Dienstag treffe ich meine Freundin Maria.
            Wir gehen zusammen ins Kino. Der Film beginnt um 19 Uhr.
            Am Mittwoch fahre ich wieder nach Hause.
            
            Bis bald!
            Anna
            """
        )
        
        let part1Q1 = GoetheA1Question(
            questionNumber: 1,
            prompt: "Anna ist in Berlin.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.richtig.id
        )
        
        let part1Q2 = GoetheA1Question(
            questionNumber: 2,
            prompt: "Anna geht am Montag ins Kino.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.falsch.id
        )
        
        let part1Q3 = GoetheA1Question(
            questionNumber: 3,
            prompt: "Der Film beginnt um 19 Uhr.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.richtig.id
        )
        
        let part1Q4 = GoetheA1Question(
            questionNumber: 4,
            prompt: "Anna trifft Maria am Dienstag.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.richtig.id
        )
        
        let part1Q5 = GoetheA1Question(
            questionNumber: 5,
            prompt: "Anna bleibt eine Woche in Berlin.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.falsch.id
        )
        
        let part1 = GoetheA1ReadingPart(
            partNumber: 1,
            title: "Teil 1: Kurze informelle Texte",
            instructions: "Lesen Sie den Text und die Aufgaben 1 bis 5. Sind die Aussagen Richtig oder Falsch?",
            textType: "informal_texts",
            texts: [part1Text],
            questions: [part1Q1, part1Q2, part1Q3, part1Q4, part1Q5]
        )
        
        // PART 2: Situation-Based Text Selection (A/B Choice)
        let part2Texts = [
            GoetheA1Text(
                title: nil,
                content: "Supermarkt EDEKA: Frische Tomaten nur heute! 1 kg für 1,99 €",
                textNumber: 1
            ),
            GoetheA1Text(
                title: nil,
                content: "Restaurant 'Zur Sonne': Heute Abend Live-Musik! Reservierung empfohlen.",
                textNumber: 2
            )
        ]
        
        let optA1 = GoetheA1Option.optionA("Sie möchten Gemüse kaufen")
        let optB1 = GoetheA1Option.optionB("Sie möchten Musik hören")
        
        let part2Q6 = GoetheA1Question(
            questionNumber: 6,
            prompt: "Sie brauchen Tomaten für das Abendessen. Welcher Text passt?",
            type: .binaryChoice,
            options: [optA1, optB1],
            correctOptionID: optA1.id
        )
        
        let optA2 = GoetheA1Option.optionA("Der Supermarkt")
        let optB2 = GoetheA1Option.optionB("Das Restaurant")
        
        let part2Q7 = GoetheA1Question(
            questionNumber: 7,
            prompt: "Wo gibt es heute Abend Live-Musik?",
            type: .binaryChoice,
            options: [optA2, optB2],
            correctOptionID: optB2.id
        )
        
        let optA3 = GoetheA1Option.optionA("1,99 €")
        let optB3 = GoetheA1Option.optionB("Kostenlos")
        
        let part2Q8 = GoetheA1Question(
            questionNumber: 8,
            prompt: "Was kosten die Tomaten?",
            type: .binaryChoice,
            options: [optA3, optB3],
            correctOptionID: optA3.id
        )
        
        let optA4 = GoetheA1Option.optionA("Ja, das ist wichtig")
        let optB4 = GoetheA1Option.optionB("Nein, das ist nicht nötig")
        
        let part2Q9 = GoetheA1Question(
            questionNumber: 9,
            prompt: "Muss man im Restaurant reservieren?",
            type: .binaryChoice,
            options: [optA4, optB4],
            correctOptionID: optA4.id
        )
        
        let optA5 = GoetheA1Option.optionA("Nur heute")
        let optB5 = GoetheA1Option.optionB("Jeden Tag")
        
        let part2Q10 = GoetheA1Question(
            questionNumber: 10,
            prompt: "Wann ist das Tomaten-Angebot?",
            type: .binaryChoice,
            options: [optA5, optB5],
            correctOptionID: optA5.id
        )
        
        let part2 = GoetheA1ReadingPart(
            partNumber: 2,
            title: "Teil 2: Alltagssituationen",
            instructions: "Lesen Sie die Texte und die Aufgaben 6 bis 10. Wählen Sie: Welcher Text passt?",
            textType: "situation_based",
            texts: part2Texts,
            questions: [part2Q6, part2Q7, part2Q8, part2Q9, part2Q10]
        )
        
        // PART 3: Notices/Signs (True/False)
        let part3Texts = [
            GoetheA1Text(
                title: "Schild am Geschäft",
                content: """
                Öffnungszeiten
                Mo-Fr: 9:00 - 18:00 Uhr
                Sa: 9:00 - 14:00 Uhr
                So: Geschlossen
                """
            ),
            GoetheA1Text(
                title: "Hinweis im Park",
                content: """
                Hunde müssen an der Leine sein
                Bitte halten Sie den Park sauber
                """
            )
        ]
        
        let part3Q11 = GoetheA1Question(
            questionNumber: 11,
            prompt: "Das Geschäft ist am Sonntag geöffnet.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.falsch.id
        )
        
        let part3Q12 = GoetheA1Question(
            questionNumber: 12,
            prompt: "Am Samstag ist das Geschäft bis 18 Uhr geöffnet.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.falsch.id
        )
        
        let part3Q13 = GoetheA1Question(
            questionNumber: 13,
            prompt: "Im Park müssen Hunde an der Leine sein.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.richtig.id
        )
        
        let part3Q14 = GoetheA1Question(
            questionNumber: 14,
            prompt: "Montags ist das Geschäft geschlossen.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.falsch.id
        )
        
        let part3Q15 = GoetheA1Question(
            questionNumber: 15,
            prompt: "Man soll den Park sauber halten.",
            type: .trueFalse,
            options: [.richtig, .falsch],
            correctOptionID: GoetheA1Option.richtig.id
        )
        
        let part3 = GoetheA1ReadingPart(
            partNumber: 3,
            title: "Teil 3: Schilder und Hinweise",
            instructions: "Lesen Sie die Texte und die Aufgaben 11 bis 15. Sind die Aussagen Richtig oder Falsch?",
            textType: "notices_signs",
            texts: part3Texts,
            questions: [part3Q11, part3Q12, part3Q13, part3Q14, part3Q15]
        )
        
        // Complete exam
        return GoetheA1ReadingExam(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            title: "Goethe A1 Lesen - Übung 1",
            level: "A1",
            examType: "goethe_a1_reading",
            duration: 25,
            totalQuestions: 15,
            parts: [part1, part2, part3],
            tags: ["goethe", "a1", "official-format", "practice"]
        )
    }
}

// MARK: - Sample Completion

extension GoetheA1ExamCompletion {
    static var sampleCompletion: GoetheA1ExamCompletion {
        GoetheA1ExamCompletion(
            userId: User.sampleUser.id,
            examId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
            level: "A1",
            score: 0.80,  // 12/15 correct
            isPassed: true,
            completedAt: Date(timeIntervalSinceNow: -3 * 24 * 60 * 60), // 3 days ago
            attemptNumber: 1,
            timeSpent: 1350 // 22:30 minutes
        )
    }
}

// MARK: - Sample Progress

extension GoetheA1UserProgress {
    static var sampleProgress: GoetheA1UserProgress {
        GoetheA1UserProgress(
            userId: User.sampleUser.id,
            level: "A1",
            completedExamIds: [UUID(uuidString: "00000000-0000-0000-0000-000000000020")!],
            totalAttempts: 2,
            averageScore: 0.75,        // Average of 2 attempts: (70% + 80%) / 2
            bestScore: 0.80,           // Best attempt: 80%
            latestScore: 0.80,         // Most recent: 80%
            isPassed: true,            // >= 60%
            part1AverageScore: 0.80,   // Part 1: 4/5 avg
            part2AverageScore: 0.70,   // Part 2: 3.5/5 avg
            part3AverageScore: 0.75,   // Part 3: 3.75/5 avg
            lastActivityAt: Date(timeIntervalSinceNow: -3 * 24 * 60 * 60) // 3 days ago
        )
    }
    
    static var notStartedProgress: GoetheA1UserProgress {
        GoetheA1UserProgress(
            userId: User.sampleUser.id,
            level: "A1",
            completedExamIds: [],
            totalAttempts: 0,
            averageScore: 0.0,
            bestScore: 0.0,
            latestScore: 0.0,
            isPassed: false,
            part1AverageScore: 0.0,
            part2AverageScore: 0.0,
            part3AverageScore: 0.0,
            lastActivityAt: Date()
        )
    }
}

