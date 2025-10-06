//
//  PuzzleService.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

class PuzzleService: ObservableObject {
    static let shared = PuzzleService()
    
    @Published var puzzles: [Puzzle] = []
    @Published var puzzleProgress: [UUID: PuzzleProgress] = [:]
    @Published var completedPuzzles: [PuzzleResult] = []
    
    private init() {
        loadPuzzles()
        loadPuzzleProgress()
        loadCompletedPuzzles()
    }
    
    private func loadPuzzles() {
        puzzles = [
            // Budget Optimization Puzzle
            Puzzle(
                title: "The Monthly Budget Challenge",
                description: "Help Sarah optimize her monthly budget to save for her vacation goal.",
                type: .budgetOptimization,
                difficulty: .easy,
                scenario: "Sarah earns $4,000 per month after taxes. Her current expenses are: Rent $1,200, Food $600, Transportation $300, Utilities $200, Entertainment $400, Shopping $500, Miscellaneous $300. She wants to save $500 per month for a vacation in 12 months.",
                question: "Which expense categories should Sarah reduce and by how much to reach her savings goal while maintaining a reasonable lifestyle?",
                correctAnswer: "Reduce Entertainment by $150 (to $250), Shopping by $200 (to $300), and Miscellaneous by $150 (to $150). This saves $500 monthly while keeping essential expenses intact.",
                hints: [
                    "Focus on non-essential categories like entertainment and shopping",
                    "Look for the largest discretionary expenses",
                    "Consider what's reasonable vs. excessive in each category"
                ],
                explanation: "By reducing entertainment from $400 to $250, shopping from $500 to $300, and miscellaneous from $300 to $150, Sarah can save exactly $500 per month. These reductions are reasonable and still allow for lifestyle enjoyment while prioritizing her vacation goal.",
                points: 50,
                estimatedTime: 10
            ),
            
            // Investment Strategy Puzzle
            Puzzle(
                title: "The Investment Allocation Dilemma",
                description: "Design an investment portfolio for a 30-year-old professional.",
                type: .investmentStrategy,
                difficulty: .medium,
                scenario: "Alex is 30 years old, has $10,000 to invest, earns $70,000 annually, and wants to retire at 65. Alex has moderate risk tolerance and wants a balanced approach between growth and stability.",
                question: "What percentage allocation would you recommend for stocks, bonds, and cash, and why?",
                correctAnswer: "70% stocks, 25% bonds, 5% cash. This follows the age-based rule (100 - age = stock percentage) with slight adjustment for moderate risk tolerance, providing growth potential while maintaining some stability.",
                hints: [
                    "Consider Alex's age and time horizon until retirement",
                    "Think about the rule of thumb: 100 minus age equals stock percentage",
                    "Balance growth needs with risk tolerance"
                ],
                explanation: "At 30, Alex has 35 years until retirement, allowing for higher risk tolerance. The 70/25/5 allocation provides growth through stocks while bonds offer stability and cash provides liquidity for emergencies.",
                points: 75,
                estimatedTime: 15
            ),
            
            // Debt Payoff Puzzle
            Puzzle(
                title: "The Debt Elimination Strategy",
                description: "Choose the best strategy to eliminate multiple debts efficiently.",
                type: .debtPayoff,
                difficulty: .medium,
                scenario: "Maria has three debts: Credit Card A ($3,000 at 18% APR, minimum $90), Credit Card B ($5,000 at 15% APR, minimum $150), Student Loan ($15,000 at 6% APR, minimum $200). She has an extra $300 monthly to put toward debt repayment.",
                question: "Should Maria use the debt snowball or debt avalanche method, and what's the optimal payment strategy?",
                correctAnswer: "Use debt avalanche: Pay minimums on all debts ($440 total), then put the extra $300 toward Credit Card A (highest interest rate). This saves the most money in interest over time.",
                hints: [
                    "Compare interest rates vs. balance amounts",
                    "Consider both psychological and mathematical benefits",
                    "Calculate total interest saved with each method"
                ],
                explanation: "The debt avalanche method (paying highest interest rate first) saves more money long-term. Credit Card A at 18% should be paid off first, then Credit Card B at 15%, then the student loan at 6%.",
                points: 60,
                estimatedTime: 12
            ),
            
            // Compound Interest Puzzle
            Puzzle(
                title: "The Power of Starting Early",
                description: "Compare the impact of starting investments at different ages.",
                type: .compoundInterest,
                difficulty: .hard,
                scenario: "Twin sisters Amy and Beth both plan to retire at 65. Amy starts investing $200/month at age 25. Beth starts investing $400/month at age 35. Both earn 7% annual return.",
                question: "Who will have more money at retirement, and by approximately how much?",
                correctAnswer: "Amy will have approximately $525,000 vs Beth's $472,000. Amy wins by about $53,000 despite investing $48,000 less total ($96,000 vs $144,000).",
                hints: [
                    "Calculate the total investment period for each sister",
                    "Remember that compound interest grows exponentially over time",
                    "Consider both the amount invested and the time factor"
                ],
                explanation: "Amy invests for 40 years ($96,000 total) while Beth invests for 30 years ($144,000 total). Despite investing less money, Amy's extra 10 years of compound growth at 7% annual return results in more wealth at retirement, demonstrating the power of starting early.",
                points: 100,
                estimatedTime: 20
            ),
            
            // Logic Puzzle
            Puzzle(
                title: "The Smart Shopping Challenge",
                description: "Optimize your shopping strategy to maximize savings.",
                type: .logicPuzzle,
                difficulty: .easy,
                scenario: "You're shopping for groceries with a $100 budget. Store A offers 10% off everything. Store B offers buy-one-get-one-free on items over $20. Store C offers $15 off purchases over $75. Your cart has items worth: $25, $30, $20, $15, $10.",
                question: "Which store gives you the best deal, and what's your final cost?",
                correctAnswer: "Store B with BOGO on $25 and $30 items. Final cost: $12.50 + $15 + $20 + $15 + $10 = $72.50. This saves $27.50 compared to the original $100.",
                hints: [
                    "Calculate the savings at each store carefully",
                    "Consider which items qualify for each store's promotion",
                    "Don't forget to check if you meet minimum purchase requirements"
                ],
                explanation: "Store A: 10% off $100 = $90. Store B: BOGO on $25 and $30 items = $72.50. Store C: $15 off $100 = $85. Store B offers the best deal with the buy-one-get-one-free promotion on qualifying items.",
                points: 40,
                estimatedTime: 8
            )
        ]
    }
    
    private func loadPuzzleProgress() {
        if let data = UserDefaults.standard.data(forKey: "puzzleProgress"),
           let decoded = try? JSONDecoder().decode([UUID: PuzzleProgress].self, from: data) {
            puzzleProgress = decoded
        }
    }
    
    private func loadCompletedPuzzles() {
        if let data = UserDefaults.standard.data(forKey: "completedPuzzles"),
           let decoded = try? JSONDecoder().decode([PuzzleResult].self, from: data) {
            completedPuzzles = decoded
        }
    }
    
    func startPuzzle(_ puzzle: Puzzle) -> PuzzleProgress {
        let progress = PuzzleProgress(puzzleId: puzzle.id)
        puzzleProgress[puzzle.id] = progress
        savePuzzleProgress()
        return progress
    }
    
    func useHint(for puzzleId: UUID) {
        puzzleProgress[puzzleId]?.hintsUsed += 1
        savePuzzleProgress()
    }
    
    func submitAnswer(for puzzleId: UUID, isCorrect: Bool) {
        guard let progress = puzzleProgress[puzzleId],
              let puzzle = puzzles.first(where: { $0.id == puzzleId }) else { return }
        
        puzzleProgress[puzzleId]?.attempts += 1
        
        if isCorrect {
            let completionTime = Date().timeIntervalSince(progress.startedAt)
            puzzleProgress[puzzleId]?.isCompleted = true
            puzzleProgress[puzzleId]?.completionTime = completionTime
            puzzleProgress[puzzleId]?.completedAt = Date()
            
            // Calculate score
            let baseScore = puzzle.points
            let hintPenalty = progress.hintsUsed * 10
            let attemptPenalty = max(0, (progress.attempts - 1) * 5)
            let finalScore = max(0, baseScore - hintPenalty - attemptPenalty)
            puzzleProgress[puzzleId]?.score = finalScore
            
            // Create result
            let result = PuzzleResult(
                puzzle: puzzle,
                hintsUsed: progress.hintsUsed,
                attempts: progress.attempts + 1,
                completionTime: completionTime,
                score: finalScore,
                completedAt: Date()
            )
            
            completedPuzzles.append(result)
            saveCompletedPuzzles()
        }
        
        savePuzzleProgress()
    }
    
    private func savePuzzleProgress() {
        if let encoded = try? JSONEncoder().encode(puzzleProgress) {
            UserDefaults.standard.set(encoded, forKey: "puzzleProgress")
        }
    }
    
    private func saveCompletedPuzzles() {
        if let encoded = try? JSONEncoder().encode(completedPuzzles) {
            UserDefaults.standard.set(encoded, forKey: "completedPuzzles")
        }
    }
    
    func getPuzzlesByType(_ type: Puzzle.PuzzleType) -> [Puzzle] {
        return puzzles.filter { $0.type == type }
    }
    
    func getPuzzlesByDifficulty(_ difficulty: Puzzle.Difficulty) -> [Puzzle] {
        return puzzles.filter { $0.difficulty == difficulty }
    }
    
    func getProgress(for puzzleId: UUID) -> PuzzleProgress? {
        return puzzleProgress[puzzleId]
    }
    
    func getUserPuzzleStats() -> (completed: Int, averageScore: Double, totalTime: TimeInterval) {
        let completed = completedPuzzles.count
        let averageScore = completedPuzzles.isEmpty ? 0 : completedPuzzles.map { $0.efficiency }.reduce(0, +) / Double(completedPuzzles.count)
        let totalTime = completedPuzzles.map { $0.completionTime }.reduce(0, +)
        
        return (completed, averageScore, totalTime)
    }
}
