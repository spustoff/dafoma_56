//
//  QuizzesView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct QuizzesView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var selectedCategory: Quiz.QuizCategory?
    @State private var selectedDifficulty: Quiz.Difficulty?
    @State private var showingQuizDetail = false
    @State private var selectedQuiz: Quiz?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.quizCompleted {
                    QuizResultView(viewModel: viewModel)
                } else if viewModel.currentQuiz != nil {
                    QuizPlayView(viewModel: viewModel)
                } else {
                    quizListView
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var quizListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                
                if !viewModel.getCompletedQuizzes().isEmpty {
                    recentResultsSection
                }
                
                filtersSection
                categoriesSection
                quizzesSection
            }
            .padding()
        }
        .navigationTitle("Quizzes")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Test Your Knowledge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Learn finance through interactive quizzes")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button("Random Quiz") {
                    if let randomQuiz = viewModel.getAllQuizzes().randomElement() {
                        startQuiz(randomQuiz)
                    }
                }
                .primaryButtonStyle()
            }
            
            // Stats Overview
            let stats = viewModel.getUserStats()
            HStack(spacing: 20) {
                StatCard(title: "Completed", value: "\(stats.totalQuizzes)", color: .appAccent)
                StatCard(title: "Avg Score", value: "\(Int(stats.averageScore))%", color: .successGreen)
                StatCard(title: "Time Spent", value: TimeFormatter.formatDuration(stats.totalTime), color: .infoBlue)
            }
        }
        .cardStyle()
        .padding(.horizontal, 4)
    }
    
    private var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Results")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.getCompletedQuizzes().suffix(5).reversed(), id: \.id) { result in
                        RecentResultCard(result: result)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var filtersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filters")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Categories",
                        isSelected: selectedCategory == nil,
                        color: .appAccent
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(Quiz.QuizCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            color: getCategoryColor(category.rawValue)
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Levels",
                        isSelected: selectedDifficulty == nil,
                        color: .appAccent
                    ) {
                        selectedDifficulty = nil
                    }
                    
                    ForEach(Quiz.Difficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            isSelected: selectedDifficulty == difficulty,
                            color: getDifficultyColor(difficulty.rawValue)
                        ) {
                            selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Quiz.QuizCategory.allCases, id: \.self) { category in
                    CategoryCard(category: category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }
    
    private var quizzesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Quizzes")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVStack(spacing: 12) {
                ForEach(filteredQuizzes, id: \.id) { quiz in
                    QuizCard(quiz: quiz) {
                        startQuiz(quiz)
                    }
                }
            }
        }
    }
    
    private var filteredQuizzes: [Quiz] {
        var quizzes = viewModel.getAllQuizzes()
        
        if let category = selectedCategory {
            quizzes = quizzes.filter { $0.category == category }
        }
        
        if let difficulty = selectedDifficulty {
            quizzes = quizzes.filter { $0.difficulty == difficulty }
        }
        
        return quizzes
    }
    
    private func startQuiz(_ quiz: Quiz) {
        withAnimation(.smooth) {
            viewModel.startQuiz(quiz)
        }
        HapticManager.lightImpact()
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "investing":
            return .investingGreen
        case "savings", "saving":
            return .savingsYellow
        case "credit & debt", "credit management":
            return .creditOrange
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "general finance":
            return .generalTeal
        case "entertainment":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner", "easy":
            return .beginnerGreen
        case "intermediate", "medium":
            return .intermediateOrange
        case "advanced", "hard":
            return .advancedRed
        case "expert":
            return .expertPurple
        default:
            return .appAccent
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct RecentResultCard: View {
    let result: QuizResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ScoreFormatter.getGradeEmoji(result.grade))
                    .font(.title2)
                
                Spacer()
                
                Text(result.grade)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.appAccent)
            }
            
            Text(result.quiz.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            Text("\(result.correctAnswers)/\(result.totalQuestions)")
                .font(.caption2)
                .foregroundColor(.textSecondary)
        }
        .padding(12)
        .frame(width: 120, height: 80)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .appBackground : color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color, lineWidth: 1)
                )
                .cornerRadius(16)
        }
    }
}

struct CategoryCard: View {
    let category: Quiz.QuizCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: categoryIcon)
                    .font(.title2)
                    .foregroundColor(getCategoryColor(category.rawValue))
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "investing":
            return .investingGreen
        case "savings", "saving":
            return .savingsYellow
        case "credit & debt", "credit management":
            return .creditOrange
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "general finance":
            return .generalTeal
        case "entertainment":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private var categoryIcon: String {
        switch category {
        case .budgeting: return "chart.pie.fill"
        case .investing: return "chart.line.uptrend.xyaxis"
        case .savings: return "banknote.fill"
        case .creditDebt: return "creditcard.fill"
        case .insurance: return "shield.fill"
        case .taxes: return "doc.text.fill"
        case .generalFinance: return "dollarsign.circle.fill"
        case .entertainment: return "tv.fill"
        }
    }
}

struct QuizCard: View {
    let quiz: Quiz
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(quiz.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Text(quiz.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(getDifficultyColor(quiz.difficulty.rawValue))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(getDifficultyColor(quiz.difficulty.rawValue).opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Text(quiz.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(getCategoryColor(quiz.category.rawValue))
                    
                    HStack {
                        Label("\(quiz.questions.count) questions", systemImage: "questionmark.circle")
                        
                        Spacer()
                        
                        Label(TimeFormatter.formatEstimatedTime(quiz.estimatedTime), systemImage: "clock")
                    }
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "investing":
            return .investingGreen
        case "savings", "saving":
            return .savingsYellow
        case "credit & debt", "credit management":
            return .creditOrange
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "general finance":
            return .generalTeal
        case "entertainment":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner", "easy":
            return .beginnerGreen
        case "intermediate", "medium":
            return .intermediateOrange
        case "advanced", "hard":
            return .advancedRed
        case "expert":
            return .expertPurple
        default:
            return .appAccent
        }
    }
}

#Preview {
    QuizzesView()
}
