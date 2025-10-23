//
//  QuizPlayView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct QuizPlayView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var showingExitAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with progress and timer
            headerView
            
            // Question content
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack {
                    
                    questionView
                    
                    // Answer options
                    answersView
                    
                    // Explanation (shown after answer selection)
                    if viewModel.showExplanation {
                        explanationView
                    }
                    
                    // Navigation button
                    navigationButton
                }
            }
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .alert("Exit Quiz?", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetQuiz()
            }
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Exit") {
                    showingExitAlert = true
                }
                .foregroundColor(.errorRed)
                
                Spacer()
                
                Text(viewModel.currentQuiz?.title ?? "Quiz")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(TimeFormatter.formatDuration(viewModel.timeElapsed))
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.cardBackground)
                    .cornerRadius(8)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.totalQuestions)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("Score: \(viewModel.score)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.appAccent)
                }
                
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
                    .scaleEffect(y: 2)
            }
        }
        .padding()
        .background(Color.appSecondary)
    }
    
    private var questionView: some View {
        VStack(spacing: 20) {
            if let question = viewModel.currentQuestion {
                Text(question.question)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text("\(question.points) points")
                    .font(.caption)
                    .foregroundColor(.appAccent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.appAccent.opacity(0.2))
                    .cornerRadius(12)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var answersView: some View {
        VStack(spacing: 12) {
            if let question = viewModel.currentQuestion {
                ForEach(0..<question.options.count, id: \.self) { index in
                    AnswerOptionView(
                        text: question.options[index],
                        index: index,
                        isSelected: viewModel.selectedAnswerIndex == index,
                        isCorrect: index == question.correctAnswerIndex,
                        showResult: viewModel.selectedAnswerIndex != nil
                    ) {
                        if viewModel.selectedAnswerIndex == nil {
                            viewModel.selectAnswer(index)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private var explanationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.appAccent)
                
                Text("Explanation")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            if let question = viewModel.currentQuestion {
                Text(question.explanation)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .slide))
    }
    
    private var navigationButton: some View {
        VStack {
            Spacer()
            
            if viewModel.showExplanation {
                Button(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question") {
                    viewModel.nextQuestion()
                }
                .primaryButtonStyle()
                .padding()
            }
        }
    }
}

struct AnswerOptionView: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let showResult: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if !showResult {
            return isSelected ? Color.appAccent.opacity(0.2) : Color.cardBackground
        } else {
            if isCorrect {
                return Color.successGreen.opacity(0.2)
            } else if isSelected && !isCorrect {
                return Color.errorRed.opacity(0.2)
            } else {
                return Color.cardBackground
            }
        }
    }
    
    var borderColor: Color {
        if !showResult {
            return isSelected ? Color.appAccent : Color.textTertiary.opacity(0.3)
        } else {
            if isCorrect {
                return Color.successGreen
            } else if isSelected && !isCorrect {
                return Color.errorRed
            } else {
                return Color.textTertiary.opacity(0.3)
            }
        }
    }
    
    var iconName: String? {
        if showResult {
            if isCorrect {
                return "checkmark.circle.fill"
            } else if isSelected && !isCorrect {
                return "xmark.circle.fill"
            }
        }
        return nil
    }
    
    var iconColor: Color {
        if isCorrect {
            return .successGreen
        } else {
            return .errorRed
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.title3)
                }
            }
            .padding()
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .disabled(showResult)
        .animation(.easeInOut(duration: 0.3), value: showResult)
    }
}

#Preview {
    QuizPlayView(viewModel: QuizViewModel())
}
