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
    
    // Sample Goethe A1 progress (future: get from AppState)
    private let goetheA1Progress = GoetheA1UserProgress.sampleProgress
    
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
    
    private func goetheStatus() -> LevelStatus {
        if !goetheA1Progress.isStarted {
            return .notStarted
        } else if goetheA1Progress.isPassed && goetheA1Progress.bestScorePercentage >= 90 {
            return .completed
        } else {
            return .inProgress
        }
    }
    
    // Smart ordering: in progress → not started → completed
    private var orderedLevels: [(level: String, progress: Any, isGoethe: Bool)] {
        var levels: [(level: String, progress: Any, status: LevelStatus, isGoethe: Bool)] = []
        
        // Add Goethe A1
        levels.append((
            level: "A1",
            progress: goetheA1Progress,
            status: goetheStatus(),
            isGoethe: true
        ))
        
        // Add regular levels (A2, B1, B2)
        for progress in appState.userProgress.filter({ $0.level != "A1" }) {
            levels.append((
                level: progress.level,
                progress: progress,
                status: levelStatus(for: progress),
                isGoethe: false
            ))
        }
        
        // Sort by status (in progress first, then not started, then completed)
        levels.sort { first, second in
            first.status.rawValue < second.status.rawValue
        }
        
        return levels.map { (level: $0.level, progress: $0.progress, isGoethe: $0.isGoethe) }
    }
    
    // Current level (first in progress level)
    private var currentLevel: String? {
        orderedLevels.first(where: { level in
            if level.isGoethe {
                let _ = level.progress as! GoetheA1UserProgress
                let status = goetheStatus()
                return status == .inProgress
            } else {
                let progress = level.progress as! UserProgress
                let status = levelStatus(for: progress)
                return status == .inProgress
            }
        })?.level
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(orderedLevels, id: \.level) { item in
                        if item.isGoethe {
                            let progress = item.progress as! GoetheA1UserProgress
                            GoetheA1ProgressCard(
                                progress: progress,
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
                                    // TODO: Navigate to Goethe A1 exams
                                    navigationPath.append("goethe_a1")
                                }
                            )
                        } else {
                            let progress = item.progress as! UserProgress
                            LevelProgressCard(
                                progress: progress,
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
                                    navigationPath.append(progress)
                                }
                            )
                        }
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
                if destination == "goethe_a1" {
                    GoetheA1ExamsView()
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
