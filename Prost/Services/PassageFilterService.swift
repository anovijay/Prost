//
//  PassageFilterService.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

/// Service responsible for filtering and sorting passages
struct PassageFilterService {
    
    // MARK: - Filtering
    
    /// Filter passages based on search criteria
    static func filterPassages(
        _ passages: [ReadingPassage],
        filters: PassageFilters,
        completionInfo: [UUID: PassageCompletionInfo]
    ) -> [ReadingPassage] {
        var filtered = passages
        
        // 1. Text search (title - case-insensitive)
        if !filters.searchText.isEmpty {
            filtered = filtered.filter { passage in
                passage.title.localizedCaseInsensitiveContains(filters.searchText)
            }
        }
        
        // 2. Tag filter (AND logic - passage must have ALL selected tags)
        if !filters.selectedTags.isEmpty {
            filtered = filtered.filter { passage in
                filters.selectedTags.isSubset(of: passage.tags)
            }
        }
        
        // 3. Completion status filter
        switch filters.completionFilter {
        case .all:
            break  // No filtering
        case .completed:
            filtered = filtered.filter { passage in
                completionInfo[passage.id] != nil
            }
        case .incomplete:
            filtered = filtered.filter { passage in
                completionInfo[passage.id] == nil
            }
        }
        
        return filtered
    }
    
    // MARK: - Sorting
    
    /// Sort passages based on sort option
    static func sortPassages(
        _ passages: [ReadingPassage],
        sortOption: PassageFilters.SortOption,
        completionInfo: [UUID: PassageCompletionInfo]
    ) -> [ReadingPassage] {
        switch sortOption {
        case .title:
            return passages.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        
        case .dateAdded:
            // Passages are already in order by date added (most recent first in array)
            return passages
        
        case .bestScore:
            return passages.sorted { p1, p2 in
                let score1 = completionInfo[p1.id]?.bestScore ?? -1.0
                let score2 = completionInfo[p2.id]?.bestScore ?? -1.0
                
                if score1 == score2 {
                    // Tie-breaker: alphabetical by title
                    return p1.title.localizedCaseInsensitiveCompare(p2.title) == .orderedAscending
                }
                return score1 > score2  // Highest score first
            }
        
        case .attempts:
            return passages.sorted { p1, p2 in
                let attempts1 = completionInfo[p1.id]?.attemptCount ?? 0
                let attempts2 = completionInfo[p2.id]?.attemptCount ?? 0
                
                if attempts1 == attempts2 {
                    // Tie-breaker: alphabetical by title
                    return p1.title.localizedCaseInsensitiveCompare(p2.title) == .orderedAscending
                }
                return attempts1 > attempts2  // Most attempts first
            }
        }
    }
    
    // MARK: - Helper
    
    /// Apply both filtering and sorting in one call
    static func applyFiltersAndSort(
        to passages: [ReadingPassage],
        filters: PassageFilters,
        completionInfo: [UUID: PassageCompletionInfo]
    ) -> [ReadingPassage] {
        let filtered = filterPassages(passages, filters: filters, completionInfo: completionInfo)
        return sortPassages(filtered, sortOption: filters.sortOption, completionInfo: completionInfo)
    }
}

