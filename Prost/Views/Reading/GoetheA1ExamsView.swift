//
//  GoetheA1ExamsView.swift
//  Prost
//
//  List of Goethe A1 practice exams
//

import SwiftUI
import SwiftData

struct GoetheA1ExamsView: View {
    let progress: UserProgress
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<DBReadingExam> { $0.level == "A1" })
    private var exams: [DBReadingExam]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if exams.isEmpty {
                    // Empty state
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No exams available")
                            .font(ProstTheme.Typography.title)
                        Text("Exam data is being loaded...")
                            .font(ProstTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(40)
                } else {
                    ForEach(exams, id: \.id) { exam in
                        NavigationLink {
                            // TODO: Navigate to exam detail
                            Text("Exam: \(exam.title)")
                        } label: {
                            ExamCardView(exam: exam)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(ProstTheme.Spacing.screenPadding)
        }
        .navigationTitle("A1 Exams")
        .navigationBarTitleDisplayMode(.inline)
        .prostBackground()
    }
}

// MARK: - Exam Card

struct ExamCardView: View {
    let exam: DBReadingExam
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(exam.title)
                    .font(ProstTheme.Typography.title)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
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

