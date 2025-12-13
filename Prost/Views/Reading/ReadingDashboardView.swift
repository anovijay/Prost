//
//  ReadingDashboardView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingDashboardView: View {
    let levels: [LevelProgress] = LevelProgress.sampleLevels
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(levels) { levelProgress in
                        NavigationLink {
                            LevelPassagesView(levelProgress: levelProgress)
                        } label: {
                            LevelProgressCard(levelProgress: levelProgress)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(ProstTheme.Spacing.screenPadding)
            }
            .navigationTitle("Reading")
            .prostBackground()
        }
    }
}

#Preview {
    ReadingDashboardView()
}
