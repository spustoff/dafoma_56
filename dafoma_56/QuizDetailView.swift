//
//  QuizDetailView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct QuizDetailView: View {
    let result: QuizResult
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    summarySection
                    questionsSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Quiz Review")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            Text("Quiz Summary")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(result.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                    Text("Points")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(ScoreFormatter.formatPercentage(result.percentage))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.successGreen)
                    Text("Accuracy")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(result.grade)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.appAccent)
                    Text("Grade")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(spacing: 4) {
                    Text(TimeFormatter.formatDuration(result.completionTime))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.infoBlue)
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Question Review")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ForEach(Array(result.quiz.questions.enumerated()), id: \.offset) { index, question in
                QuestionReviewCard(
                    question: question,
                    questionNumber: index + 1
                )
            }
        }
    }
}

struct QuestionReviewCard: View {
    let question: QuizQuestion
    let questionNumber: Int
    @State private var showExplanation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question header
            HStack {
                Text("Question \(questionNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.appAccent)
                
                Spacer()
                
                Text("\(question.points) pts")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            // Question text
            Text(question.question)
                .font(.body)
                .foregroundColor(.textPrimary)
                .lineLimit(nil)
            
            // Answer options
            VStack(spacing: 8) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    HStack {
                        Image(systemName: index == question.correctAnswerIndex ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(index == question.correctAnswerIndex ? .successGreen : .textTertiary)
                        
                        Text(option)
                            .font(.body)
                            .foregroundColor(index == question.correctAnswerIndex ? .successGreen : .textSecondary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // Explanation toggle
            Button(action: {
                withAnimation(.smooth) {
                    showExplanation.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                    Text(showExplanation ? "Hide Explanation" : "Show Explanation")
                    Spacer()
                    Image(systemName: showExplanation ? "chevron.up" : "chevron.down")
                }
                .font(.caption)
                .foregroundColor(.appAccent)
            }
            
            if showExplanation {
                Text(question.explanation)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding()
                    .background(Color.appSecondary)
                    .cornerRadius(8)
                    .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    QuizDetailView(result: QuizResult(
        quiz: Quiz(
            title: "Sample Quiz",
            category: .budgeting,
            questions: [],
            difficulty: .beginner,
            estimatedTime: 5
        ),
        score: 85,
        totalPoints: 100,
        completionTime: 300,
        correctAnswers: 8,
        totalQuestions: 10,
        completedAt: Date()
    ))
}
