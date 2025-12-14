//
//  A1PartsView.swift
//  Prost
//
//  Shows A1 exam parts (Part 1, Part 2, Part 3)
//

import SwiftUI

struct A1PartsView: View {
    @EnvironmentObject private var appState: AppState
    
    // Calculate completion stats for each part
    private var part1Stats: PartStats {
        calculatePartStats(tags: ["part1"])
    }
    
    private var part2Stats: PartStats {
        calculatePartStats(tags: ["part2"])
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Part 1 Card
                NavigationLink {
                    A1Part1PracticesView()
                } label: {
                    PartCardView(
                        partNumber: 1,
                        title: "Informal Texts",
                        description: "Read short texts and answer True/False questions",
                        totalPractices: 50,
                        stats: part1Stats,
                        icon: "envelope.fill"
                    )
                }
                .buttonStyle(.plain)
                
                // Part 2 Card
                NavigationLink {
                    A1Part2PracticesView()
                } label: {
                    PartCardView(
                        partNumber: 2,
                        title: "Situations",
                        description: "Choose between two options based on a situation",
                        totalPractices: 25,
                        stats: part2Stats,
                        icon: "arrow.left.arrow.right"
                    )
                }
                .buttonStyle(.plain)
                
                // Part 3 Card (Coming Soon)
                PartCardView(
                    partNumber: 3,
                    title: "Signs & Notices",
                    description: "Coming soon",
                    totalPractices: 0,
                    stats: PartStats(completed: 0, bestScore: 0),
                    icon: "signpost.right.fill",
                    isDisabled: true
                )
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("A1 Reading Parts")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
    }
    
    // MARK: - Helper Methods
    
    private func calculatePartStats(tags: [String]) -> PartStats {
        // Get all passages with these tags from completions
        let partCompletions = appState.completions.filter { completion in
            // We need to check if this completion belongs to a part by checking passage tags
            // Since we don't have passage reference here, we'll estimate based on level
            completion.level == "A1" && completion.userId == appState.currentUser.id
        }
        
        let uniquePassages = Set(partCompletions.map { $0.passageId })
        let bestScore = partCompletions.map { $0.score }.max() ?? 0.0
        
        return PartStats(completed: uniquePassages.count, bestScore: bestScore)
    }
}

// MARK: - Part Card View

struct PartCardView: View {
    let partNumber: Int
    let title: String
    let description: String
    let totalPractices: Int
    let stats: PartStats
    let icon: String
    var isDisabled: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.secondary.opacity(0.1) : Color.accentColor.opacity(0.12))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isDisabled ? .secondary : Color.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Part \(partNumber): \(title)")
                        .font(ProstTheme.Typography.title.weight(.semibold))
                        .foregroundStyle(isDisabled ? .secondary : .primary)
                    
                    if isDisabled {
                        Text("Soon")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(ProstTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                if !isDisabled {
                    HStack(spacing: 12) {
                        // Total practices
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.caption)
                            Text("\(totalPractices) practices")
                                .font(ProstTheme.Typography.caption)
                        }
                        
                        // Completed count
                        if stats.completed > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Text("\(stats.completed) done")
                                    .font(ProstTheme.Typography.caption)
                            }
                        }
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if !isDisabled {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .prostCard()
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Supporting Types

struct PartStats {
    let completed: Int
    let bestScore: Double
}

#Preview {
    NavigationStack {
        A1PartsView()
            .environmentObject(AppState())
    }
}

