//
//  QuizResultView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct QuizResultView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var showingDetails = false
    @State private var animateScore = false
    
    private var result: QuizResult? {
        guard let quiz = viewModel.currentQuiz else { return nil }
        let totalPoints = quiz.questions.reduce(0) { $0 + $1.points }
        return QuizResult(
            quiz: quiz,
            score: viewModel.score,
            totalPoints: totalPoints,
            completionTime: viewModel.timeElapsed,
            correctAnswers: viewModel.correctAnswers,
            totalQuestions: quiz.questions.count,
            completedAt: Date()
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerView
                scoreView
                statsView
                performanceView
                actionButtons
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.bouncy.delay(0.3)) {
                    animateScore = true
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Celebration animation
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateScore ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateScore)
                
                Text(result?.grade ?? "")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.appAccent)
                    .scaleEffect(animateScore ? 1.0 : 0.5)
                    .animation(.bouncy.delay(0.2), value: animateScore)
            }
            
            VStack(spacing: 8) {
                Text("Quiz Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(viewModel.currentQuiz?.title ?? "")
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                
                if let result = result {
                    Text(ScoreFormatter.getPerformanceMessage(result.percentage))
                        .font(.body)
                        .foregroundColor(.appAccent)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    private var scoreView: some View {
        VStack(spacing: 20) {
            if let result = result {
                // Main score display
                VStack(spacing: 8) {
                    Text("\(result.score)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.appAccent)
                        .scaleEffect(animateScore ? 1.0 : 0.8)
                        .animation(.bouncy.delay(0.4), value: animateScore)
                    
                    Text("out of \(result.totalPoints) points")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                }
                
                // Percentage and grade
                HStack(spacing: 30) {
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
                        HStack {
                            Text(ScoreFormatter.getGradeEmoji(result.grade))
                                .font(.title2)
                            Text(result.grade)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.appAccent)
                        }
                        
                        Text("Grade")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var statsView: some View {
        VStack(spacing: 16) {
            Text("Quiz Statistics")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if let result = result {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatItem(
                        icon: "checkmark.circle.fill",
                        title: "Correct",
                        value: "\(result.correctAnswers)",
                        color: .successGreen
                    )
                    
                    StatItem(
                        icon: "xmark.circle.fill",
                        title: "Incorrect",
                        value: "\(result.totalQuestions - result.correctAnswers)",
                        color: .errorRed
                    )
                    
                    StatItem(
                        icon: "clock.fill",
                        title: "Time",
                        value: TimeFormatter.formatDuration(result.completionTime),
                        color: .infoBlue
                    )
                    
                    StatItem(
                        icon: "questionmark.circle.fill",
                        title: "Questions",
                        value: "\(result.totalQuestions)",
                        color: .appAccent
                    )
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var performanceView: some View {
        VStack(spacing: 16) {
            Text("Performance Analysis")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if let result = result {
                VStack(alignment: .leading, spacing: 12) {
                    PerformanceRow(
                        title: "Speed",
                        description: getSpeedAnalysis(result.completionTime, totalQuestions: result.totalQuestions),
                        color: .infoBlue
                    )
                    
                    PerformanceRow(
                        title: "Accuracy",
                        description: getAccuracyAnalysis(result.percentage),
                        color: .successGreen
                    )
                    
                    PerformanceRow(
                        title: "Difficulty",
                        description: getDifficultyAnalysis(),
                        color: .warningOrange
                    )
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button("Try Again") {
                if let quiz = viewModel.currentQuiz {
                    viewModel.resetQuiz()
                    viewModel.startQuiz(quiz)
                }
            }
            .primaryButtonStyle()
            
            Button("Back to Quizzes") {
                viewModel.resetQuiz()
            }
            .secondaryButtonStyle()
            
            Button("View Details") {
                showingDetails = true
            }
            .foregroundColor(.appAccent)
        }
        .sheet(isPresented: $showingDetails) {
            if let result = result {
                QuizDetailView(result: result)
            }
        }
    }
    
    private func getSpeedAnalysis(_ time: TimeInterval, totalQuestions: Int) -> String {
        let avgTimePerQuestion = time / Double(totalQuestions)
        
        if avgTimePerQuestion < 30 {
            return "Lightning fast! You answered quickly and confidently."
        } else if avgTimePerQuestion < 60 {
            return "Good pace! You took your time to think through each question."
        } else {
            return "Thoughtful approach! You carefully considered each answer."
        }
    }
    
    private func getAccuracyAnalysis(_ percentage: Double) -> String {
        switch percentage {
        case 90...100:
            return "Excellent! You have a strong grasp of the material."
        case 80..<90:
            return "Very good! You understand most concepts well."
        case 70..<80:
            return "Good work! There's room for improvement in some areas."
        case 60..<70:
            return "Fair performance. Consider reviewing the material."
        default:
            return "Keep studying! Practice will help you improve."
        }
    }
    
    private func getDifficultyAnalysis() -> String {
        guard let difficulty = viewModel.currentQuiz?.difficulty else {
            return "Challenge completed!"
        }
        
        switch difficulty {
        case .beginner:
            return "Great start! Ready for intermediate challenges?"
        case .intermediate:
            return "Solid understanding! Consider trying advanced quizzes."
        case .advanced:
            return "Impressive! You've mastered advanced concepts."
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(Color.appSecondary)
        .cornerRadius(12)
    }
}

struct PerformanceRow: View {
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
    }
}

#Preview {
    QuizResultView(viewModel: QuizViewModel())
}
