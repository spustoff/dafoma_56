//
//  Puzzle.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Puzzle: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: PuzzleType
    let difficulty: Difficulty
    let scenario: String
    let question: String
    let correctAnswer: String
    let hints: [String]
    let explanation: String
    let points: Int
    let estimatedTime: Int // in minutes
    
    enum PuzzleType: String, CaseIterable, Codable {
        case budgetOptimization = "Budget Optimization"
        case investmentStrategy = "Investment Strategy"
        case debtPayoff = "Debt Payoff"
        case savingsGoal = "Savings Goal"
        case riskAssessment = "Risk Assessment"
        case compoundInterest = "Compound Interest"
        case taxOptimization = "Tax Optimization"
        case logicPuzzle = "Logic Puzzle"
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
    }
}

struct PuzzleProgress: Identifiable, Codable {
    let id = UUID()
    let puzzleId: UUID
    var hintsUsed: Int = 0
    var attempts: Int = 0
    var isCompleted: Bool = false
    var completionTime: TimeInterval?
    var score: Int = 0
    let startedAt: Date = Date()
    var completedAt: Date?
}

struct PuzzleResult: Identifiable, Codable {
    let id = UUID()
    let puzzle: Puzzle
    let hintsUsed: Int
    let attempts: Int
    let completionTime: TimeInterval
    let score: Int
    let completedAt: Date
    
    var efficiency: Double {
        let maxScore = puzzle.points
        let hintPenalty = hintsUsed * 10
        let attemptPenalty = max(0, (attempts - 1) * 5)
        let finalScore = max(0, maxScore - hintPenalty - attemptPenalty)
        return Double(finalScore) / Double(maxScore) * 100
    }
}
