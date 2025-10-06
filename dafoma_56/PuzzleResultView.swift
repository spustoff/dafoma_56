//
//  PuzzleResultView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct PuzzleResultView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var animateScore = false
    
    private var result: PuzzleResult? {
        guard let puzzle = viewModel.currentPuzzle,
              let progress = viewModel.currentProgress,
              progress.isCompleted else { return nil }
        
        return PuzzleResult(
            puzzle: puzzle,
            hintsUsed: progress.hintsUsed,
            attempts: progress.attempts,
            completionTime: progress.completionTime ?? 0,
            score: progress.score,
            completedAt: progress.completedAt ?? Date()
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
                
                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.appAccent)
                    .scaleEffect(animateScore ? 1.0 : 0.5)
                    .animation(.bouncy.delay(0.2), value: animateScore)
            }
            
            VStack(spacing: 8) {
                Text("Puzzle Solved!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(viewModel.currentPuzzle?.title ?? "")
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                
                if let result = result {
                    Text(getPerformanceMessage(result.efficiency))
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
                    
                    Text("out of \(result.puzzle.points) points")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                }
                
                // Efficiency and grade
                HStack(spacing: 30) {
                    VStack(spacing: 4) {
                        Text(String(format: "%.0f%%", result.efficiency))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.successGreen)
                        
                        Text("Efficiency")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text(getEfficiencyGrade(result.efficiency))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccent)
                        
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
            Text("Puzzle Statistics")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if let result = result {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatItem(
                        icon: "target",
                        title: "Attempts",
                        value: "\(result.attempts)",
                        color: .infoBlue
                    )
                    
                    StatItem(
                        icon: "lightbulb.fill",
                        title: "Hints Used",
                        value: "\(result.hintsUsed)",
                        color: .warningOrange
                    )
                    
                    StatItem(
                        icon: "clock.fill",
                        title: "Time",
                        value: TimeFormatter.formatDuration(result.completionTime),
                        color: .infoBlue
                    )
                    
                    StatItem(
                        icon: "star.fill",
                        title: "Points",
                        value: "\(result.score)",
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
                        title: "Problem Solving",
                        description: getAttemptAnalysis(result.attempts),
                        color: .infoBlue
                    )
                    
                    PerformanceRow(
                        title: "Independence",
                        description: getHintAnalysis(result.hintsUsed),
                        color: .warningOrange
                    )
                    
                    PerformanceRow(
                        title: "Efficiency",
                        description: getTimeAnalysis(result.completionTime),
                        color: .successGreen
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
            Button("Try Another Puzzle") {
                viewModel.resetPuzzle()
            }
            .primaryButtonStyle()
            
            Button("Back to Puzzles") {
                viewModel.resetPuzzle()
            }
            .secondaryButtonStyle()
        }
    }
    
    private func getPerformanceMessage(_ efficiency: Double) -> String {
        switch efficiency {
        case 90...100: return "Outstanding! Perfect execution!"
        case 80..<90: return "Excellent! Great problem-solving skills!"
        case 70..<80: return "Good work! You solved it efficiently!"
        case 60..<70: return "Nice job! Room for improvement in efficiency."
        case 50..<60: return "You got it! Try to use fewer hints next time."
        default: return "Solved! Keep practicing to improve efficiency."
        }
    }
    
    private func getEfficiencyGrade(_ efficiency: Double) -> String {
        switch efficiency {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        case 50..<60: return "D"
        default: return "F"
        }
    }
    
    private func getAttemptAnalysis(_ attempts: Int) -> String {
        switch attempts {
        case 1: return "Perfect! You solved it on the first try."
        case 2: return "Great! You quickly corrected your approach."
        case 3: return "Good persistence! Third time's the charm."
        default: return "Excellent persistence! You didn't give up."
        }
    }
    
    private func getHintAnalysis(_ hintsUsed: Int) -> String {
        switch hintsUsed {
        case 0: return "Amazing! You solved it completely independently."
        case 1: return "Excellent! You only needed minimal guidance."
        case 2: return "Good! You used hints strategically."
        default: return "You used available resources wisely to solve the puzzle."
        }
    }
    
    private func getTimeAnalysis(_ time: TimeInterval) -> String {
        let minutes = Int(time / 60)
        
        switch minutes {
        case 0..<5: return "Lightning fast! You're a quick thinker."
        case 5..<10: return "Good pace! You balanced speed with accuracy."
        case 10..<20: return "Thoughtful approach! You took time to analyze."
        default: return "Thorough analysis! You carefully considered all aspects."
        }
    }
}

#Preview {
    PuzzleResultView(viewModel: PuzzleViewModel())
}
