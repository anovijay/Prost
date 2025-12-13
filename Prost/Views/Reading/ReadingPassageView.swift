//
//  ReadingPassageView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingPassageView: View {
    let passage: ReadingPassage

    @State private var goToQuestions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(passage.text)
                    .font(ProstTheme.Typography.body)
                    .foregroundStyle(.primary)
                    .lineSpacing(6)
                    .textSelection(.enabled)
                    .prostCard()

                Spacer(minLength: 80)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                goToQuestions = true
            } label: {
                Text("Continue to Questions")
                    .font(ProstTheme.Typography.title)
                    .frame(maxWidth: .infinity)
                    .padding(16)
            }
            .buttonStyle(.borderedProminent)
            .padding(ProstTheme.Spacing.screenPadding)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(passage.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .navigationDestination(isPresented: $goToQuestions) {
            ReadingQuestionsView(passage: passage)
        }
    }
}
