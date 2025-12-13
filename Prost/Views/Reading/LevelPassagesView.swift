//
//  LevelPassagesView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct LevelPassagesView: View {
    let progress: UserProgress
    
    @EnvironmentObject private var appState: AppState
    @State private var filters = PassageFilters()
    @State private var showTagFilterSheet = false
    
    // Sample passages for this level (future: fetch from backend filtered by level)
    private let passages: [ReadingPassage] = [.sampleBerlinDay]
    
    // Build completion info for all passages
    private var passageCompletionInfo: [UUID: PassageCompletionInfo] {
        var info: [UUID: PassageCompletionInfo] = [:]
        for passage in passages {
            let history = appState.getCompletionHistory(for: passage.id)
            if !history.isEmpty {
                let bestScore = history.map { $0.score }.max() ?? 0.0
                info[passage.id] = PassageCompletionInfo(
                    attemptCount: history.count,
                    bestScore: bestScore
                )
            }
        }
        return info
    }
    
    // Apply filters and sorting
    private var filteredAndSortedPassages: [ReadingPassage] {
        PassageFilterService.applyFiltersAndSort(
            to: passages,
            filters: filters,
            completionInfo: passageCompletionInfo
        )
    }
    
    // Extract all unique tags from passages
    private var availableTags: [String] {
        Array(Set(passages.flatMap { $0.tags })).sorted()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Search bar
                SearchBar(
                    text: $filters.searchText,
                    placeholder: "Search passages..."
                )
                
                // Filter chips (horizontal scroll)
                if !passages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            // Completion filter chips
                            ForEach(PassageFilters.CompletionFilter.allCases) { filter in
                                FilterChip(
                                    title: filter.rawValue,
                                    systemImage: filter.systemImage,
                                    isSelected: filters.completionFilter == filter,
                                    action: { filters.completionFilter = filter }
                                )
                            }
                            
                            Divider()
                                .frame(height: 20)
                            
                            // Sort menu
                            Menu {
                                ForEach(PassageFilters.SortOption.allCases) { option in
                                    Button {
                                        filters.sortOption = option
                                    } label: {
                                        Label(option.rawValue, systemImage: option.systemImage)
                                    }
                                }
                            } label: {
                                FilterChip(
                                    title: "Sort: \(filters.sortOption.rawValue)",
                                    systemImage: "arrow.up.arrow.down",
                                    isSelected: filters.sortOption != .title
                                )
                            }
                            
                            // Tag filter button
                            if !availableTags.isEmpty {
                                Button {
                                    showTagFilterSheet = true
                                } label: {
                                    FilterChip(
                                        title: filters.selectedTags.isEmpty ? "Tags" : "Tags (\(filters.selectedTags.count))",
                                        systemImage: "tag",
                                        isSelected: !filters.selectedTags.isEmpty
                                    )
                                }
                            }
                            
                            // Clear all filters button
                            if filters.isActive {
                                Button {
                                    filters = PassageFilters()
                                } label: {
                                    FilterChip(
                                        title: "Clear",
                                        systemImage: "xmark",
                                        isSelected: false
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Passage list or empty state
                if filteredAndSortedPassages.isEmpty {
                    EmptyStateView(
                        icon: filters.isActive ? "magnifyingglass" : "book",
                        title: filters.isActive ? "No passages found" : "No passages available",
                        message: filters.isActive ? "Try adjusting your filters" : "Check back later for new content"
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(filteredAndSortedPassages) { passage in
                        NavigationLink {
                            ReadingPassageView(passage: passage)
                        } label: {
                            PassageCardView(
                                title: passage.title,
                                questionCount: passage.questions.count,
                                completionInfo: passageCompletionInfo[passage.id]
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle(progress.level)
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .sheet(isPresented: $showTagFilterSheet) {
            TagFilterSheet(
                availableTags: availableTags,
                selectedTags: $filters.selectedTags
            )
        }
    }
}

// MARK: - Supporting Types

struct PassageCompletionInfo {
    let attemptCount: Int
    let bestScore: Double
    
    var bestScorePercentage: Int {
        Int(bestScore * 100)
    }
}

// MARK: - Passage Card Component

struct PassageCardView: View {
    let title: String
    let questionCount: Int
    let completionInfo: PassageCompletionInfo?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    // Question count
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("\(questionCount) questions")
                            .font(ProstTheme.Typography.caption)
                    }
                    .foregroundStyle(.secondary)
                    
                    // Attempt count (if completed)
                    if let info = completionInfo {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                            Text("\(info.attemptCount) attempt\(info.attemptCount == 1 ? "" : "s")")
                                .font(ProstTheme.Typography.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Completion status with best score
                if let info = completionInfo {
                    HStack(spacing: 4) {
                        if info.bestScore == 1.0 {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                        Text("\(info.bestScorePercentage)%")
                            .font(ProstTheme.Typography.body.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.body)
                        .foregroundStyle(.secondary.opacity(0.3))
                }
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .prostCard()
    }
}
