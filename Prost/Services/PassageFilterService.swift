//
//  PassageFilterService.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

// NOTE: The filtering logic now lives in an array extension to keep the architecture
// lean and colocated with the data it operates on.
extension Array where Element == ReadingPassage {
    func applying(filters: PassageFilters, completionInfo: [UUID: PassageCompletionInfo]) -> [ReadingPassage] {
        var filtered = self

        if !filters.searchText.isEmpty {
            filtered = filtered.filter { passage in
                passage.title.localizedCaseInsensitiveContains(filters.searchText)
            }
        }

        if !filters.selectedTags.isEmpty {
            filtered = filtered.filter { passage in
                filters.selectedTags.isSubset(of: passage.tags)
            }
        }

        switch filters.completionFilter {
        case .all:
            break
        case .completed:
            filtered = filtered.filter { passage in
                completionInfo[passage.id] != nil
            }
        case .incomplete:
            filtered = filtered.filter { passage in
                completionInfo[passage.id] == nil
            }
        }

        switch filters.sortOption {
        case .title:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .dateAdded:
            return filtered
        case .bestScore:
            return filtered.sorted { p1, p2 in
                let score1 = completionInfo[p1.id]?.bestScore ?? -1.0
                let score2 = completionInfo[p2.id]?.bestScore ?? -1.0

                if score1 == score2 {
                    return p1.title.localizedCaseInsensitiveCompare(p2.title) == .orderedAscending
                }
                return score1 > score2
            }
        case .attempts:
            return filtered.sorted { p1, p2 in
                let attempts1 = completionInfo[p1.id]?.attemptCount ?? 0
                let attempts2 = completionInfo[p2.id]?.attemptCount ?? 0

                if attempts1 == attempts2 {
                    return p1.title.localizedCaseInsensitiveCompare(p2.title) == .orderedAscending
                }
                return attempts1 > attempts2
            }
        }
    }
}
