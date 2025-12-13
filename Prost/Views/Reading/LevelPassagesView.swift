//
//  LevelPassagesView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelPassagesView: View {
    let progress: UserProgress
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Sample passage for this level
                NavigationLink {
                    ReadingPassageView(passage: .sampleBerlinDay)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ein Tag in Berlin")
                                .font(ProstTheme.Typography.title)
                            Text("3 questions")
                                .font(ProstTheme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // Show completion status if passage is completed
                        if progress.completedPassageIds.contains(ReadingPassage.sampleBerlinDay.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .foregroundStyle(.green)
                        }
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .prostCard()
                }
                .buttonStyle(.plain)
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle(progress.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
    }
}
