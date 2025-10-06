//
//  QuizViewModel.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int?
    @Published var showExplanation = false
    @Published var quizCompleted = false
    @Published var score = 0
    @Published var correctAnswers = 0
    @Published var startTime: Date?
    @Published var timeElapsed: TimeInterval = 0
    @Published var timer: Timer?
    
    private let quizService = QuizService.shared
    
    var currentQuestion: QuizQuestion? {
        guard let quiz = currentQuiz,
              currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard let quiz = currentQuiz else { return 0 }
        return Double(currentQuestionIndex) / Double(quiz.questions.count)
    }
    
    var isLastQuestion: Bool {
        guard let quiz = currentQuiz else { return false }
        return currentQuestionIndex == quiz.questions.count - 1
    }
    
    var totalQuestions: Int {
        currentQuiz?.questions.count ?? 0
    }
    
    func startQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showExplanation = false
        quizCompleted = false
        score = 0
        correctAnswers = 0
        startTime = Date()
        timeElapsed = 0
        
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                self.timeElapsed = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func selectAnswer(_ index: Int) {
        guard selectedAnswerIndex == nil else { return }
        
        selectedAnswerIndex = index
        
        if let question = currentQuestion {
            if index == question.correctAnswerIndex {
                score += question.points
                correctAnswers += 1
                HapticManager.success()
            } else {
                HapticManager.error()
            }
        }
        
        // Show explanation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.smooth) {
                self.showExplanation = true
            }
        }
    }
    
    func nextQuestion() {
        if isLastQuestion {
            completeQuiz()
        } else {
            withAnimation(.smooth) {
                currentQuestionIndex += 1
                selectedAnswerIndex = nil
                showExplanation = false
            }
        }
    }
    
    private func completeQuiz() {
        timer?.invalidate()
        timer = nil
        
        guard let quiz = currentQuiz, let startTime = startTime else { return }
        
        let completionTime = Date().timeIntervalSince(startTime)
        let totalPoints = quiz.questions.reduce(0) { $0 + $1.points }
        
        let result = QuizResult(
            quiz: quiz,
            score: score,
            totalPoints: totalPoints,
            completionTime: completionTime,
            correctAnswers: correctAnswers,
            totalQuestions: quiz.questions.count,
            completedAt: Date()
        )
        
        quizService.saveQuizResult(result)
        
        withAnimation(.smooth) {
            quizCompleted = true
        }
        
        HapticManager.success()
    }
    
    func resetQuiz() {
        timer?.invalidate()
        timer = nil
        currentQuiz = nil
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showExplanation = false
        quizCompleted = false
        score = 0
        correctAnswers = 0
        startTime = nil
        timeElapsed = 0
    }
    
    func getQuizzesByCategory(_ category: Quiz.QuizCategory) -> [Quiz] {
        return quizService.getQuizzesByCategory(category)
    }
    
    func getQuizzesByDifficulty(_ difficulty: Quiz.Difficulty) -> [Quiz] {
        return quizService.getQuizzesByDifficulty(difficulty)
    }
    
    func getAllQuizzes() -> [Quiz] {
        return quizService.quizzes
    }
    
    func getCompletedQuizzes() -> [QuizResult] {
        return quizService.completedQuizzes
    }
    
    func getUserStats() -> (totalQuizzes: Int, averageScore: Double, totalTime: TimeInterval) {
        return quizService.getUserStats()
    }
    
    deinit {
        timer?.invalidate()
    }
}
