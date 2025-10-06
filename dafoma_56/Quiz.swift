//
//  Quiz.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct Quiz: Identifiable, Codable {
    let id = UUID()
    let title: String
    let category: QuizCategory
    let questions: [QuizQuestion]
    let difficulty: Difficulty
    let estimatedTime: Int // in minutes
    
    enum QuizCategory: String, CaseIterable, Codable {
        case budgeting = "Budgeting"
        case investing = "Investing"
        case savings = "Savings"
        case creditDebt = "Credit & Debt"
        case insurance = "Insurance"
        case taxes = "Taxes"
        case generalFinance = "General Finance"
        case entertainment = "Entertainment"
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

struct QuizQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
    let points: Int
}

struct QuizResult: Identifiable, Codable {
    let id = UUID()
    let quiz: Quiz
    let score: Int
    let totalPoints: Int
    let completionTime: TimeInterval
    let correctAnswers: Int
    let totalQuestions: Int
    let completedAt: Date
    
    var percentage: Double {
        return Double(score) / Double(totalPoints) * 100
    }
    
    var grade: String {
        switch percentage {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        case 50..<60: return "D"
        default: return "F"
        }
    }
}
