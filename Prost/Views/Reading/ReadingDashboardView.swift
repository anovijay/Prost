//
//  ReadingDashboardView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingDashboardView: View {
    @EnvironmentObject private var appState: AppState
    
    // Sample Goethe A1 progress (future: get from AppState)
    private let goetheA1Progress = GoetheA1UserProgress.sampleProgress
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Special card for A1 (Goethe format)
                    NavigationLink {
                        // TODO: Navigate to Goethe A1 exam list
                        Text("Goethe A1 Exams - Coming Soon")
                            .prostBackground()
                    } label: {
                        GoetheA1ProgressCard(progress: goetheA1Progress)
                    }
                    .buttonStyle(.plain)
                    
                    // Regular cards for A2, B1, B2
                    ForEach(appState.userProgress.filter { $0.level != "A1" }) { userProgress in
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
