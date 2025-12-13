//
//  PlaceholderTabView.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

struct PlaceholderTabView: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(ProstTheme.Typography.hero)
            Text("Coming soon")
                .font(ProstTheme.Typography.body)
                .foregroundStyle(.secondary)
        }
        .prostBackground()
    }
}
