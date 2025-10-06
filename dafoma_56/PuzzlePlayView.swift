//
//  PuzzlePlayView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct PuzzlePlayView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var showingExitAlert = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Puzzle content
            ScrollView {
                VStack(spacing: 20) {
                    scenarioView
                    questionView
                    answerInputView
                    
                    if viewModel.showHint {
                        hintView
                    }
                    
                    if viewModel.showSolution {
                        solutionView
                    }
                }
                .padding()
            }
            
            // Bottom actions
            bottomActionsView
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .alert("Exit Puzzle?", isPresented: $showingExitAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Exit", role: .destructive) {
                viewModel.resetPuzzle()
            }
        } message: {
            Text("Your progress will be lost if you exit now.")
        }
        .onTapGesture {
            isTextFieldFocused = false
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
                
                Text(viewModel.currentPuzzle?.title ?? "Puzzle")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.appAccent)
                    Text("\(viewModel.hintsUsed)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.cardBackground)
                .cornerRadius(8)
            }
            
            if let puzzle = viewModel.currentPuzzle {
                HStack {
                    Text(puzzle.type.rawValue)
                        .font(.caption)
                        .foregroundColor(getCategoryColor(puzzle.type.rawValue))
                    
                    Spacer()
                    
                    Text(puzzle.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(getDifficultyColor(puzzle.difficulty.rawValue))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(getDifficultyColor(puzzle.difficulty.rawValue).opacity(0.2))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(puzzle.points) points")
                        .font(.caption)
                        .foregroundColor(.appAccent)
                }
            }
        }
        .padding()
        .background(Color.appSecondary)
    }
    
    private var scenarioView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.infoBlue)
                
                Text("Scenario")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            if let puzzle = viewModel.currentPuzzle {
                Text(puzzle.scenario)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.appAccent)
                
                Text("Question")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            if let puzzle = viewModel.currentPuzzle {
                Text(puzzle.question)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .lineLimit(nil)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var answerInputView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.successGreen)
                
                Text("Your Answer")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if viewModel.attempts > 0 {
                    Text("Attempt \(viewModel.attempts + 1)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            TextEditor(text: $viewModel.userAnswer)
                .focused($isTextFieldFocused)
                .font(.body)
                .foregroundColor(.textPrimary)
                .padding(12)
                .background(Color.appSecondary)
                .cornerRadius(8)
                .frame(minHeight: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.appAccent.opacity(0.3), lineWidth: 1)
                )
            
            if viewModel.userAnswer.isEmpty {
                Text("Type your detailed answer here...")
                    .font(.body)
                    .foregroundColor(.textTertiary)
                    .padding(.leading, 16)
                    .padding(.top, -88)
                    .allowsHitTesting(false)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
    
    private var hintView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.warningOrange)
                
                Text("Hint \(viewModel.currentHintIndex + 1)")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if viewModel.canShowMoreHints {
                    Button("Next Hint") {
                        viewModel.showNextHint()
                    }
                    .font(.caption)
                    .foregroundColor(.appAccent)
                }
            }
            
            if let hint = viewModel.currentHint {
                Text(hint)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .lineLimit(nil)
            }
        }
        .padding()
        .background(Color.warningOrange.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.warningOrange.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .transition(.opacity.combined(with: .slide))
    }
    
    private var solutionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.successGreen)
                
                Text("Solution")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            if let puzzle = viewModel.currentPuzzle {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Correct Answer:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.successGreen)
                    
                    Text(puzzle.correctAnswer)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .lineLimit(nil)
                    
                    Text("Explanation:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.successGreen)
                        .padding(.top, 8)
                    
                    Text(puzzle.explanation)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineLimit(nil)
                }
            }
        }
        .padding()
        .background(Color.successGreen.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.successGreen.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
        .transition(.opacity.combined(with: .slide))
    }
    
    private var bottomActionsView: some View {
        VStack(spacing: 12) {
            if !viewModel.isCompleted && !viewModel.showSolution {
                HStack(spacing: 16) {
                    if !viewModel.showHint && !viewModel.availableHints.isEmpty {
                        Button("Get Hint") {
                            viewModel.useHint()
                        }
                        .secondaryButtonStyle()
                    }
                    
                    Button("Submit Answer") {
                        isTextFieldFocused = false
                        viewModel.submitAnswer()
                    }
                    .primaryButtonStyle(isEnabled: !viewModel.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .disabled(viewModel.userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            
            if viewModel.attempts > 0 && !viewModel.isCompleted && !viewModel.showSolution {
                Button("Show Solution") {
                    viewModel.showSolutionExplanation()
                }
                .foregroundColor(.warningOrange)
                .font(.caption)
            }
            
            if viewModel.isCompleted || viewModel.showSolution {
                Button("Continue") {
                    if viewModel.isCompleted {
                        withAnimation(.smooth) {
                            viewModel.showingResult = true
                        }
                    } else {
                        viewModel.resetPuzzle()
                    }
                }
                .primaryButtonStyle()
            }
        }
        .padding()
        .background(Color.appSecondary)
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
    PuzzlePlayView(viewModel: PuzzleViewModel())
}
