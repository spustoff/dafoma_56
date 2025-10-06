//
//  QuizService.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

class QuizService: ObservableObject {
    static let shared = QuizService()
    
    @Published var quizzes: [Quiz] = []
    @Published var completedQuizzes: [QuizResult] = []
    
    private init() {
        loadQuizzes()
        loadCompletedQuizzes()
    }
    
    private func loadQuizzes() {
        quizzes = [
            // Budgeting Quizzes
            Quiz(
                title: "Budgeting Basics",
                category: .budgeting,
                questions: [
                    QuizQuestion(
                        question: "What percentage of your income should ideally go to housing costs?",
                        options: ["20%", "30%", "40%", "50%"],
                        correctAnswerIndex: 1,
                        explanation: "The 30% rule suggests that no more than 30% of your gross monthly income should go to housing costs including rent, mortgage, insurance, and utilities.",
                        points: 10
                    ),
                    QuizQuestion(
                        question: "What is the 50/30/20 budgeting rule?",
                        options: [
                            "50% needs, 30% wants, 20% savings",
                            "50% savings, 30% needs, 20% wants",
                            "50% wants, 30% savings, 20% needs",
                            "50% housing, 30% food, 20% entertainment"
                        ],
                        correctAnswerIndex: 0,
                        explanation: "The 50/30/20 rule allocates 50% of after-tax income to needs, 30% to wants, and 20% to savings and debt repayment.",
                        points: 15
                    ),
                    QuizQuestion(
                        question: "Which expense category should you prioritize first in your budget?",
                        options: ["Entertainment", "Essential needs", "Luxury items", "Hobbies"],
                        correctAnswerIndex: 1,
                        explanation: "Essential needs like housing, food, utilities, and transportation should always be prioritized first in any budget.",
                        points: 10
                    )
                ],
                difficulty: .beginner,
                estimatedTime: 5
            ),
            
            // Investing Quizzes
            Quiz(
                title: "Investment Fundamentals",
                category: .investing,
                questions: [
                    QuizQuestion(
                        question: "What is compound interest?",
                        options: [
                            "Interest paid only on the principal",
                            "Interest paid on both principal and accumulated interest",
                            "A type of bank account",
                            "A government bond"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Compound interest is interest calculated on the initial principal and also on the accumulated interest from previous periods.",
                        points: 15
                    ),
                    QuizQuestion(
                        question: "What does diversification mean in investing?",
                        options: [
                            "Putting all money in one stock",
                            "Spreading investments across different assets",
                            "Only investing in bonds",
                            "Timing the market perfectly"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "Diversification involves spreading investments across various assets to reduce risk and potential losses.",
                        points: 15
                    ),
                    QuizQuestion(
                        question: "What is a good strategy for beginner investors?",
                        options: [
                            "Day trading",
                            "Picking individual stocks",
                            "Dollar-cost averaging into index funds",
                            "Investing in cryptocurrency only"
                        ],
                        correctAnswerIndex: 2,
                        explanation: "Dollar-cost averaging into diversified index funds is often recommended for beginners as it reduces risk and requires less expertise.",
                        points: 20
                    )
                ],
                difficulty: .intermediate,
                estimatedTime: 7
            ),
            
            // Savings Quiz
            Quiz(
                title: "Smart Saving Strategies",
                category: .savings,
                questions: [
                    QuizQuestion(
                        question: "How much should you aim to have in an emergency fund?",
                        options: ["1 month of expenses", "3-6 months of expenses", "1 year of expenses", "2 years of expenses"],
                        correctAnswerIndex: 1,
                        explanation: "Financial experts typically recommend having 3-6 months of living expenses saved in an emergency fund for unexpected situations.",
                        points: 15
                    ),
                    QuizQuestion(
                        question: "What is the best place to keep your emergency fund?",
                        options: [
                            "Stock market",
                            "High-yield savings account",
                            "Under your mattress",
                            "Cryptocurrency"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "A high-yield savings account provides liquidity, safety, and some interest growth for emergency funds.",
                        points: 10
                    )
                ],
                difficulty: .beginner,
                estimatedTime: 4
            ),
            
            // Entertainment Quiz
            Quiz(
                title: "Financial Pop Culture",
                category: .entertainment,
                questions: [
                    QuizQuestion(
                        question: "In the movie 'The Big Short', what financial crisis was depicted?",
                        options: [
                            "The Great Depression",
                            "The 2008 Housing Crisis",
                            "The Dot-com Bubble",
                            "The 1987 Stock Market Crash"
                        ],
                        correctAnswerIndex: 1,
                        explanation: "The Big Short depicted the events leading up to the 2008 financial crisis caused by the housing market collapse.",
                        points: 10
                    ),
                    QuizQuestion(
                        question: "What does 'HODL' mean in cryptocurrency culture?",
                        options: [
                            "Hold On for Dear Life",
                            "High Order Digital Ledger",
                            "A misspelling of 'hold'",
                            "Both A and C"
                        ],
                        correctAnswerIndex: 3,
                        explanation: "HODL originated as a misspelling of 'hold' but is now commonly interpreted as 'Hold On for Dear Life' in crypto communities.",
                        points: 5
                    )
                ],
                difficulty: .beginner,
                estimatedTime: 3
            )
        ]
    }
    
    private func loadCompletedQuizzes() {
        // Load from UserDefaults or local storage
        if let data = UserDefaults.standard.data(forKey: "completedQuizzes"),
           let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            completedQuizzes = decoded
        }
    }
    
    func saveQuizResult(_ result: QuizResult) {
        completedQuizzes.append(result)
        if let encoded = try? JSONEncoder().encode(completedQuizzes) {
            UserDefaults.standard.set(encoded, forKey: "completedQuizzes")
        }
    }
    
    func getQuizzesByCategory(_ category: Quiz.QuizCategory) -> [Quiz] {
        return quizzes.filter { $0.category == category }
    }
    
    func getQuizzesByDifficulty(_ difficulty: Quiz.Difficulty) -> [Quiz] {
        return quizzes.filter { $0.difficulty == difficulty }
    }
    
    func getRandomQuiz() -> Quiz? {
        return quizzes.randomElement()
    }
    
    func getUserStats() -> (totalQuizzes: Int, averageScore: Double, totalTime: TimeInterval) {
        let totalQuizzes = completedQuizzes.count
        let averageScore = completedQuizzes.isEmpty ? 0 : completedQuizzes.map { $0.percentage }.reduce(0, +) / Double(completedQuizzes.count)
        let totalTime = completedQuizzes.map { $0.completionTime }.reduce(0, +)
        
        return (totalQuizzes, averageScore, totalTime)
    }
}
