//
//  QuestionCardView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct QuestionCardView: View {
    let number: Int
    let question: ReadingQuestion
    @Binding var selectedOptionID: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Q\(number)")
                    .font(ProstTheme.Typography.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(question.prompt)
                    .font(ProstTheme.Typography.title)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(question.options) { option in
                    OptionRowView(
                        text: option.text,
                        isSelected: selectedOptionID == option.id,
                        onSelect: { selectedOptionID = option.id }
                    )
                }
            }
        }
        .prostCard()
    }
}

struct OptionRowView: View {
    let text: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.4))
                Text(text)
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isSelected ? ProstTheme.Colors.accentSoft : Color(white: 0.97))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(isSelected ? ProstTheme.Colors.accentBorder : Color.gray.opacity(0.15), lineWidth: 1.5)
                )
        )
    }
}

