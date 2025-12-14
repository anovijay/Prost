//
//  ReadingDashboardView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct ReadingDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var expandedLevels: Set<String> = []
    @State private var navigationPath = NavigationPath()
    
    // Determine level status for smart ordering
    private func levelStatus(for progress: UserProgress) -> LevelStatus {
        if progress.completedCount == 0 && progress.totalAttempts == 0 {
            return .notStarted
        } else if progress.bestScorePercentage >= 90 {
            return .completed // 90%+ = mastered
        } else {
            return .inProgress
        }
    }
    
    // Smart ordering: in progress → not started → completed
    private var orderedLevels: [(level: String, progress: UserProgress)] {
        var levels: [(level: String, progress: UserProgress, status: LevelStatus)] = []
        
        // Add all levels including A1
        for progress in appState.userProgress {
            levels.append((
                level: progress.level,
                progress: progress,
                status: levelStatus(for: progress)
            ))
        }
        
        // Sort by status (in progress first, then not started, then completed)
        levels.sort { first, second in
            first.status.rawValue < second.status.rawValue
        }
        
        return levels.map { (level: $0.level, progress: $0.progress) }
    }
    
    // Current level (first in progress level)
    private var currentLevel: String? {
        orderedLevels.first(where: { level in
            let status = levelStatus(for: level.progress)
            return status == .inProgress
        })?.level
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(orderedLevels, id: \.level) { item in
                        LevelProgressCard(
                            progress: item.progress,
                            isExpanded: Binding(
                                get: { expandedLevels.contains(item.level) },
                                set: { isExpanded in
                                    if isExpanded {
                                        expandedLevels.insert(item.level)
                                    } else {
                                        expandedLevels.remove(item.level)
                                    }
                                }
                            ),
                            onNavigate: {
                                // Special navigation for A1 (goes to parts overview)
                                if item.level == "A1" {
                                    navigationPath.append("a1_parts")
                                } else {
                                    navigationPath.append(item.progress)
                                }
                            }
                        )
                    }
                }
                .padding(ProstTheme.Spacing.screenPadding)
            }
            .navigationTitle("Reading")
            .prostBackground()
            .navigationDestination(for: UserProgress.self) { progress in
                LevelPassagesView(progress: progress)
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "a1_parts" {
                    A1PartsView()
                }
            }
        }
        .onAppear {
            // Expand current level by default
            if let current = currentLevel {
                expandedLevels.insert(current)
            }
        }
    }
}

// MARK: - Level Status

enum LevelStatus: Int {
    case inProgress = 0    // First in order
    case notStarted = 1    // Second in order
    case completed = 2     // Last in order
}

#Preview {
    ReadingDashboardView()
}
