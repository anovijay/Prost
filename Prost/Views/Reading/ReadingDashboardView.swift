//
//  ReadingDashboardView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingDashboardView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(appState.userProgress) { userProgress in
                        NavigationLink {
                            LevelPassagesView(progress: userProgress)
                        } label: {
                            LevelProgressCard(progress: userProgress)
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
