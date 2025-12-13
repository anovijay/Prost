//
//  PassageFilters.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import Foundation

/// Model representing all filter and sort options for passages
struct PassageFilters: Codable, Equatable {
    var searchText: String = ""
    var selectedTags: Set<String> = []
    var completionFilter: CompletionFilter = .all
    var sortOption: SortOption = .title
    
    /// Check if any filters are active (non-default)
    var isActive: Bool {
        !searchText.isEmpty ||
        !selectedTags.isEmpty ||
        completionFilter != .all ||
        sortOption != .title
    }
    
    // MARK: - Completion Filter
    
    enum CompletionFilter: String, Codable, CaseIterable, Identifiable {
        case all = "All"
        case completed = "Completed"
        case incomplete = "Not Started"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .completed: return "checkmark.circle.fill"
            case .incomplete: return "circle"
            }
        }
    }
    
    // MARK: - Sort Option
    
    enum SortOption: String, Codable, CaseIterable, Identifiable {
        case title = "Title"
        case dateAdded = "Recently Added"
        case bestScore = "Best Score"
        case attempts = "Most Attempts"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .title: return "textformat"
            case .dateAdded: return "clock"
            case .bestScore: return "star.fill"
            case .attempts: return "arrow.clockwise"
            }
        }
    }
}

