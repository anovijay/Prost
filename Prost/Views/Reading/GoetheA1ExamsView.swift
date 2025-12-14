//
//  GoetheA1ExamsView.swift
//  Prost
//
//  List of Goethe A1 practice exams loaded from JSON
//

import SwiftUI

struct GoetheA1ExamsView: View {
    @State private var exams: [GoetheA1ReadingExam] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isLoading {
                    // Loading state
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading exams...")
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
                        Text("Failed to load exams")
                            .font(ProstTheme.Typography.title)
                        Text(error)
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Retry") {
                            loadExams()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else if exams.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No exams available")
                            .font(ProstTheme.Typography.title)
                        Text("Check back later for new practice exams")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else {
                    // Exams list
                    ForEach(exams) { exam in
                        NavigationLink {
                            // TODO: Navigate to exam detail/start view
                            Text("Exam: \(exam.title)")
                                .prostBackground()
                        } label: {
                            GoetheExamCardView(exam: exam)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("Goethe A1 Exams")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
        .task {
            loadExams()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadExams() {
        isLoading = true
        errorMessage = nil
        
        do {
            exams = try GoetheA1JSONLoader.loadGoetheA1Exams()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Failed to load Goethe A1 exams: \(error)")
        }
    }
}

// MARK: - Exam Card

struct GoetheExamCardView: View {
    let exam: GoetheA1ReadingExam
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(exam.title)
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                        Text("\(exam.parts.count) parts")
                            .font(ProstTheme.Typography.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("\(exam.totalQuestions) questions")
                            .font(ProstTheme.Typography.caption)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(exam.duration) min")
                            .font(ProstTheme.Typography.caption)
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

