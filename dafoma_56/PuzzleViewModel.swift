//
//  PuzzleViewModel.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class PuzzleViewModel: ObservableObject {
    @Published var currentPuzzle: Puzzle?
    @Published var currentProgress: PuzzleProgress?
    @Published var userAnswer = ""
    @Published var showHint = false
    @Published var currentHintIndex = 0
    @Published var showSolution = false
    @Published var isCompleted = false
    @Published var showingResult = false
    
    private let puzzleService = PuzzleService.shared
    
    var availableHints: [String] {
        currentPuzzle?.hints ?? []
    }
    
    var currentHint: String? {
        guard let hints = currentPuzzle?.hints,
              currentHintIndex < hints.count else { return nil }
        return hints[currentHintIndex]
    }
    
    var canShowMoreHints: Bool {
        guard let puzzle = currentPuzzle else { return false }
        return currentHintIndex < puzzle.hints.count - 1
    }
    
    var hintsUsed: Int {
        currentProgress?.hintsUsed ?? 0
    }
    
    var attempts: Int {
        currentProgress?.attempts ?? 0
    }
    
    func startPuzzle(_ puzzle: Puzzle) {
        currentPuzzle = puzzle
        currentProgress = puzzleService.startPuzzle(puzzle)
        userAnswer = ""
        showHint = false
        currentHintIndex = 0
        showSolution = false
        isCompleted = false
        showingResult = false
    }
    
    func useHint() {
        guard let puzzle = currentPuzzle else { return }
        
        puzzleService.useHint(for: puzzle.id)
        currentProgress = puzzleService.getProgress(for: puzzle.id)
        
        withAnimation(.smooth) {
            showHint = true
        }
        
        HapticManager.lightImpact()
    }
    
    func showNextHint() {
        guard canShowMoreHints else { return }
        
        withAnimation(.smooth) {
            currentHintIndex += 1
        }
        
        useHint()
    }
    
    func submitAnswer() {
        guard let puzzle = currentPuzzle,
              !userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            HapticManager.error()
            return
        }
        
        let isCorrect = checkAnswer()
        puzzleService.submitAnswer(for: puzzle.id, isCorrect: isCorrect)
        currentProgress = puzzleService.getProgress(for: puzzle.id)
        
        if isCorrect {
            withAnimation(.smooth) {
                isCompleted = true
                showingResult = true
            }
            HapticManager.success()
        } else {
            // Show a brief feedback for incorrect answer
            withAnimation(.easeInOut(duration: 0.15)) {
                // Could add a shake animation or color change here
            }
            HapticManager.error()
        }
    }
    
    private func checkAnswer() -> Bool {
        guard let puzzle = currentPuzzle else { return false }
        
        let userAnswerCleaned = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswerCleaned = puzzle.correctAnswer.lowercased()
        
        // Simple keyword matching - in a real app, you might want more sophisticated matching
        let userWords = Set(userAnswerCleaned.components(separatedBy: .whitespacesAndNewlines))
        let correctWords = Set(correctAnswerCleaned.components(separatedBy: .whitespacesAndNewlines))
        
        // Check if user answer contains key concepts from the correct answer
        let keyWords = ["debt", "avalanche", "snowball", "interest", "rate", "minimum", "payment", "stocks", "bonds", "cash", "allocation", "percentage", "budget", "reduce", "save", "entertainment", "shopping"]
        
        let userKeyWords = userWords.intersection(Set(keyWords))
        let correctKeyWords = correctWords.intersection(Set(keyWords))
        
        // If user mentioned at least 60% of the key concepts, consider it correct
        if !correctKeyWords.isEmpty {
            let matchPercentage = Double(userKeyWords.intersection(correctKeyWords).count) / Double(correctKeyWords.count)
            return matchPercentage >= 0.6
        }
        
        // Fallback to simple string matching
        return userAnswerCleaned.contains(correctAnswerCleaned) || correctAnswerCleaned.contains(userAnswerCleaned)
    }
    
    func showSolutionExplanation() {
        withAnimation(.smooth) {
            showSolution = true
        }
    }
    
    func resetPuzzle() {
        currentPuzzle = nil
        currentProgress = nil
        userAnswer = ""
        showHint = false
        currentHintIndex = 0
        showSolution = false
        isCompleted = false
        showingResult = false
    }
    
    func getPuzzlesByType(_ type: Puzzle.PuzzleType) -> [Puzzle] {
        return puzzleService.getPuzzlesByType(type)
    }
    
    func getPuzzlesByDifficulty(_ difficulty: Puzzle.Difficulty) -> [Puzzle] {
        return puzzleService.getPuzzlesByDifficulty(difficulty)
    }
    
    func getAllPuzzles() -> [Puzzle] {
        return puzzleService.puzzles
    }
    
    func getCompletedPuzzles() -> [PuzzleResult] {
        return puzzleService.completedPuzzles
    }
    
    func getUserPuzzleStats() -> (completed: Int, averageScore: Double, totalTime: TimeInterval) {
        return puzzleService.getUserPuzzleStats()
    }
    
    func getProgress(for puzzleId: UUID) -> PuzzleProgress? {
        return puzzleService.getProgress(for: puzzleId)
    }
}
