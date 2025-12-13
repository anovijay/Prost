//
//  TagFilterSheet.swift
//  Prost
//
//  Created by Anoop Vijayan on 13.12.25.
//

import SwiftUI

/// Sheet for selecting multiple tags to filter passages
struct TagFilterSheet: View {
    let availableTags: [String]
    @Binding var selectedTags: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if availableTags.isEmpty {
                        Text("No tags available")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableTags, id: \.self) { tag in
                            Button {
                                toggleTag(tag)
                            } label: {
                                HStack {
                                    Image(systemName: "tag")
                                        .foregroundStyle(.secondary)
                                    Text(tag.capitalized)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                            .font(.body.weight(.semibold))
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Select tags to filter")
                } footer: {
                    if selectedTags.count > 1 {
                        Text("Passages must have ALL selected tags")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Filter by Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        selectedTags.removeAll()
                    }
                    .disabled(selectedTags.isEmpty)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Actions
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }
}

#Preview {
    TagFilterSheet(
        availableTags: ["travel", "food", "daily-life", "culture", "work"],
        selectedTags: .constant(["travel", "food"])
    )
}

