//
//  PuzzlesView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct PuzzlesView: View {
    @StateObject private var viewModel = PuzzleViewModel()
    @State private var selectedType: Puzzle.PuzzleType?
    @State private var selectedDifficulty: Puzzle.Difficulty?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if viewModel.showingResult {
                    PuzzleResultView(viewModel: viewModel)
                } else if viewModel.currentPuzzle != nil {
                    PuzzlePlayView(viewModel: viewModel)
                } else {
                    puzzleListView
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var puzzleListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                
                if !viewModel.getCompletedPuzzles().isEmpty {
                    recentResultsSection
                }
                
                filtersSection
                typesSection
                puzzlesSection
            }
            .padding()
        }
        .navigationTitle("Puzzles")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Solve Financial Puzzles")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Challenge yourself with real-world scenarios")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button("Random Puzzle") {
                    if let randomPuzzle = viewModel.getAllPuzzles().randomElement() {
                        startPuzzle(randomPuzzle)
                    }
                }
                .primaryButtonStyle()
            }
            
            // Stats Overview
            let stats = viewModel.getUserPuzzleStats()
            HStack(spacing: 20) {
                StatCard(title: "Completed", value: "\(stats.completed)", color: .appAccent)
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
                    ForEach(viewModel.getCompletedPuzzles().suffix(5).reversed(), id: \.id) { result in
                        PuzzleResultCard(result: result)
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
                        title: "All Types",
                        isSelected: selectedType == nil,
                        color: .appAccent
                    ) {
                        selectedType = nil
                    }
                    
                    ForEach(Puzzle.PuzzleType.allCases, id: \.self) { type in
                        FilterChip(
                            title: type.rawValue,
                            isSelected: selectedType == type,
                            color: getCategoryColor(type.rawValue)
                        ) {
                            selectedType = selectedType == type ? nil : type
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
                    
                    ForEach(Puzzle.Difficulty.allCases, id: \.self) { difficulty in
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
    
    private var typesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Puzzle Types")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(Puzzle.PuzzleType.allCases, id: \.self) { type in
                    PuzzleTypeCard(type: type) {
                        selectedType = type
                    }
                }
            }
        }
    }
    
    private var puzzlesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available Puzzles")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVStack(spacing: 12) {
                ForEach(filteredPuzzles, id: \.id) { puzzle in
                    PuzzleCard(puzzle: puzzle) {
                        startPuzzle(puzzle)
                    }
                }
            }
        }
    }
    
    private var filteredPuzzles: [Puzzle] {
        var puzzles = viewModel.getAllPuzzles()
        
        if let type = selectedType {
            puzzles = puzzles.filter { $0.type == type }
        }
        
        if let difficulty = selectedDifficulty {
            puzzles = puzzles.filter { $0.difficulty == difficulty }
        }
        
        return puzzles
    }
    
    private func startPuzzle(_ puzzle: Puzzle) {
        withAnimation(.smooth) {
            viewModel.startPuzzle(puzzle)
        }
        HapticManager.lightImpact()
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting", "budget optimization":
            return .budgetingBlue
        case "investing", "investment strategy":
            return .investingGreen
        case "savings", "saving", "savings goal":
            return .savingsYellow
        case "debt", "debt payoff":
            return .creditOrange
        case "insurance", "risk assessment":
            return .insurancePurple
        case "taxes", "tax optimization":
            return .taxesRed
        case "compound interest":
            return .generalTeal
        case "logic puzzle":
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

struct PuzzleResultCard: View {
    let result: PuzzleResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "puzzlepiece.fill")
                    .foregroundColor(.appAccent)
                
                Spacer()
                
                Text("\(Int(result.efficiency))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.successGreen)
            }
            
            Text(result.puzzle.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
                .lineLimit(2)
            
            HStack {
                Text("\(result.attempts) attempts")
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text("\(result.hintsUsed) hints")
                    .font(.caption2)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(12)
        .frame(width: 140, height: 90)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct PuzzleTypeCard: View {
    let type: Puzzle.PuzzleType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: typeIcon)
                    .font(.title2)
                    .foregroundColor(getCategoryColor(type.rawValue))
                
                Text(type.rawValue)
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
        case "budgeting", "budget optimization":
            return .budgetingBlue
        case "investing", "investment strategy":
            return .investingGreen
        case "savings", "saving", "savings goal":
            return .savingsYellow
        case "debt", "debt payoff":
            return .creditOrange
        case "insurance", "risk assessment":
            return .insurancePurple
        case "taxes", "tax optimization":
            return .taxesRed
        case "compound interest":
            return .generalTeal
        case "logic puzzle":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private var typeIcon: String {
        switch type {
        case .budgetOptimization: return "chart.pie.fill"
        case .investmentStrategy: return "chart.line.uptrend.xyaxis"
        case .debtPayoff: return "creditcard.fill"
        case .savingsGoal: return "banknote.fill"
        case .riskAssessment: return "shield.fill"
        case .compoundInterest: return "percent"
        case .taxOptimization: return "doc.text.fill"
        case .logicPuzzle: return "brain.head.profile"
        }
    }
}

struct PuzzleCard: View {
    let puzzle: Puzzle
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(puzzle.title)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text(puzzle.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(getDifficultyColor(puzzle.difficulty.rawValue))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getDifficultyColor(puzzle.difficulty.rawValue).opacity(0.2))
                        .cornerRadius(8)
                }
                
                Text(puzzle.description)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
                
                Text(puzzle.type.rawValue)
                    .font(.caption)
                    .foregroundColor(getCategoryColor(puzzle.type.rawValue))
                
                HStack {
                    Label("\(puzzle.points) points", systemImage: "star.fill")
                    
                    Spacer()
                    
                    Label(TimeFormatter.formatEstimatedTime(puzzle.estimatedTime), systemImage: "clock")
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting", "budget optimization":
            return .budgetingBlue
        case "investing", "investment strategy":
            return .investingGreen
        case "savings", "saving", "savings goal":
            return .savingsYellow
        case "debt", "debt payoff":
            return .creditOrange
        case "insurance", "risk assessment":
            return .insurancePurple
        case "taxes", "tax optimization":
            return .taxesRed
        case "compound interest":
            return .generalTeal
        case "logic puzzle":
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
    PuzzlesView()
}
