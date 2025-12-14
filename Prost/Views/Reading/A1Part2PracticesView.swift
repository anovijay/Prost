//
//  A1Part2PracticesView.swift
//  Prost
//
//  List of A1 Part 2 practices (situation-based A/B choice questions)
//

import SwiftUI

struct A1Part2PracticesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var practices: [ReadingPassage] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // Build completion info for all practices
    private var practiceCompletionInfo: [UUID: PracticeCompletionInfo] {
        var info: [UUID: PracticeCompletionInfo] = [:]
        for practice in practices {
            let history = appState.completionHistory(for: practice.id)
            if !history.isEmpty {
                let bestScore = history.map { $0.score }.max() ?? 0.0
                info[practice.id] = PracticeCompletionInfo(
                    attemptCount: history.count,
                    bestScore: bestScore
                )
            }
        }
        return info
    }
    
    // Sort practices: incomplete first, then completed
    private var sortedPractices: [ReadingPassage] {
        practices.sorted { practice1, practice2 in
            let isCompleted1 = appState.isCompleted(practice1.id)
            let isCompleted2 = appState.isCompleted(practice2.id)
            
            // If one is completed and the other isn't, incomplete comes first
            if isCompleted1 != isCompleted2 {
                return !isCompleted1
            }
            
            // Otherwise maintain original order
            return false
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading practices...")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else if let error = errorMessage {
                    // Error state
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)
                        Text("Failed to load practices")
                            .font(ProstTheme.Typography.title)
                        Text(error)
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            loadPractices()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else if practices.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No practices available")
                            .font(ProstTheme.Typography.title)
                        Text("Check back later for new practices")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else {
                    // Practices list (sorted: incomplete first, completed at bottom)
                    ForEach(sortedPractices) { practice in
                        NavigationLink {
                            Part2PracticeView(passage: practice)
                        } label: {
                            Part2PracticeCardView(
                                practice: practice,
                                completionInfo: practiceCompletionInfo[practice.id]
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("A1 Part 2: Situations")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .task {
            loadPractices()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadPractices() {
        isLoading = true
        errorMessage = nil
        
        do {
            practices = try Part2JSONLoader.loadPart2Practices()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Failed to load A1 Part 2 practices: \(error)")
        }
    }
}

// MARK: - Part 2 Practice Card

struct Part2PracticeCardView: View {
    let practice: ReadingPassage
    let completionInfo: PracticeCompletionInfo?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(practice.title)
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.primary)
                
                // Show situation preview
                Text(practice.text)
                    .font(ProstTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("A/B Choice")
                            .font(ProstTheme.Typography.caption)
                    }
                    
                    // Completion status
                    if let info = completionInfo {
                        HStack(spacing: 4) {
                            if info.bestScore == 1.0 {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                            Text("\(Int(info.bestScore * 100))%")
                                .font(ProstTheme.Typography.caption.weight(.medium))
                        }
                        .foregroundStyle(.green)
                    }
                }
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
}

#Preview {
    NavigationStack {
        A1Part2PracticesView()
            .environmentObject(AppState())
    }
}

