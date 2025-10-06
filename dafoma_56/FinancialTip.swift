//
//  FinancialTip.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

struct FinancialTip: Identifiable, Codable {
    let id = UUID()
    let title: String
    let category: TipCategory
    let content: String
    let keyTakeaways: [String]
    let actionItems: [String]
    let difficulty: Difficulty
    let readingTime: Int // in minutes
    let tags: [String]
    let relatedTopics: [String]
    
    enum TipCategory: String, CaseIterable, Codable {
        case budgeting = "Budgeting"
        case saving = "Saving"
        case investing = "Investing"
        case creditManagement = "Credit Management"
        case debtReduction = "Debt Reduction"
        case emergencyFund = "Emergency Fund"
        case retirement = "Retirement Planning"
        case insurance = "Insurance"
        case taxes = "Tax Planning"
        case realEstate = "Real Estate"
        case sideHustle = "Side Hustle"
        case mindset = "Financial Mindset"
    }
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }
}

struct InteractiveTip: Identifiable {
    let id = UUID()
    let tip: FinancialTip
    let interactiveElements: [InteractiveElement]
    
    struct InteractiveElement: Identifiable {
        let id = UUID()
        let type: ElementType
        let title: String
        let content: String
        let options: [String]?
        let correctAnswer: String?
        
        enum ElementType {
            case calculator
            case quiz
            case checklist
            case scenario
            case comparison
        }
    }
}

struct TipProgress: Identifiable, Codable {
    let id = UUID()
    let tipId: UUID
    var isRead: Bool = false
    var isBookmarked: Bool = false
    var completedActionItems: [Int] = []
    var readAt: Date?
    var timeSpent: TimeInterval = 0
    
    var completionPercentage: Double {
        guard let tip = FinanceTipService.shared.getTip(by: tipId) else { return 0 }
        let totalItems = tip.actionItems.count
        guard totalItems > 0 else { return isRead ? 100 : 0 }
        return Double(completedActionItems.count) / Double(totalItems) * 100
    }
}
