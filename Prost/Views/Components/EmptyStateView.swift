//
//  EmptyStateView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

/// Reusable empty state component for no results/content scenarios
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(ProstTheme.Typography.title)
                .foregroundStyle(.primary)
            
            Text(message)
                .font(ProstTheme.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No passages found",
            message: "Try adjusting your filters"
        )
        
        EmptyStateView(
            icon: "book",
            title: "No passages available",
            message: "Check back later for new content"
        )
    }
}

