//
//  LevelPassagesView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelPassagesView: View {
    let levelProgress: LevelProgress
    
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
        .navigationTitle(levelProgress.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
    }
}
