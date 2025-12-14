//
//  GoetheQuestionCardView.swift
//  Prost
//
//  Reusable question card for Goethe A1 exam questions (Richtig/Falsch, A/B choice)
//

import SwiftUI

struct GoetheQuestionCardView: View {
    let question: GoetheA1Question
    let number: Int
    @Binding var selectedOptionID: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question header
            HStack(alignment: .top, spacing: 8) {
                Text("Q\(number)")
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.secondary)
                
                Text(question.prompt)
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
            }
            
            // Options
            VStack(spacing: 8) {
                ForEach(question.options) { option in
                    GoetheOptionRowView(
                        option: option,
                        isSelected: selectedOptionID == option.id,
                        onSelect: {
                            selectedOptionID = option.id
                        }
                    )
                }
            }
        }
        .prostCard()
    }
}

// MARK: - Option Row

struct GoetheOptionRowView: View {
    let option: GoetheA1Option
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                
                // Option text
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.text)
                        .font(ProstTheme.Typography.title)
                        .foregroundStyle(.primary)
                    
                    // Show value if it's different from text (e.g., A/B choices)
                    if option.text != option.value && !option.value.isEmpty {
                        Text(option.value)
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let richtigOption = GoetheA1Option(text: "Richtig", value: "True")
    let falschOption = GoetheA1Option(text: "Falsch", value: "False")
    
    let question = GoetheA1Question(
        questionNumber: 1,
        prompt: "Sara ist heute bis 15 Uhr im Büro.",
        type: .trueFalse,
        options: [richtigOption, falschOption],
        correctOptionID: richtigOption.id
    )
    
    return GoetheQuestionCardView(
        question: question,
        number: 1,
        selectedOptionID: .constant(nil)
    )
    .padding()
    .prostBackground()
}

