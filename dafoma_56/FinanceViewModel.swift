//
//  FinanceViewModel.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class FinanceViewModel: ObservableObject {
    @Published var tips: [FinancialTip] = []
    @Published var filteredTips: [FinancialTip] = []
    @Published var selectedCategory: FinancialTip.TipCategory?
    @Published var selectedDifficulty: FinancialTip.Difficulty?
    @Published var searchText = ""
    @Published var showingBookmarksOnly = false
    
    private let financeService = FinanceTipService.shared
    
    init() {
        loadTips()
    }
    
    private func loadTips() {
        tips = financeService.tips
        applyFilters()
    }
    
    func applyFilters() {
        var result = tips
        
        // Apply category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            result = result.filter { $0.difficulty == difficulty }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            result = financeService.searchTips(searchText)
        }
        
        // Apply bookmarks filter
        if showingBookmarksOnly {
            result = result.filter { financeService.bookmarkedTips.contains($0.id) }
        }
        
        filteredTips = result
    }
    
    func setCategory(_ category: FinancialTip.TipCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    func setDifficulty(_ difficulty: FinancialTip.Difficulty?) {
        selectedDifficulty = difficulty
        applyFilters()
    }
    
    func updateSearchText(_ text: String) {
        searchText = text
        applyFilters()
    }
    
    func toggleBookmarksOnly() {
        showingBookmarksOnly.toggle()
        applyFilters()
    }
    
    func clearFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        searchText = ""
        showingBookmarksOnly = false
        applyFilters()
    }
    
    func markTipAsRead(_ tipId: UUID) {
        financeService.markTipAsRead(tipId)
    }
    
    func toggleBookmark(_ tipId: UUID) {
        financeService.toggleBookmark(tipId)
        // Refresh filtered tips if showing bookmarks only
        if showingBookmarksOnly {
            applyFilters()
        }
    }
    
    func completeActionItem(_ tipId: UUID, itemIndex: Int) {
        financeService.completeActionItem(tipId, itemIndex: itemIndex)
    }
    
    func uncompleteActionItem(_ tipId: UUID, itemIndex: Int) {
        financeService.uncompleteActionItem(tipId, itemIndex: itemIndex)
    }
    
    func getProgress(for tipId: UUID) -> TipProgress? {
        return financeService.getProgress(for: tipId)
    }
    
    func isBookmarked(_ tipId: UUID) -> Bool {
        return financeService.bookmarkedTips.contains(tipId)
    }
    
    func getBookmarkedTips() -> [FinancialTip] {
        return financeService.getBookmarkedTips()
    }
    
    func getTipsByCategory(_ category: FinancialTip.TipCategory) -> [FinancialTip] {
        return financeService.getTipsByCategory(category)
    }
    
    func getTipsByDifficulty(_ difficulty: FinancialTip.Difficulty) -> [FinancialTip] {
        return financeService.getTipsByDifficulty(difficulty)
    }
    
    // Statistics
    func getReadingStats() -> (totalTips: Int, readTips: Int, bookmarkedTips: Int, completedActionItems: Int) {
        let totalTips = tips.count
        let readTips = financeService.tipProgress.values.filter { $0.isRead }.count
        let bookmarkedTips = financeService.bookmarkedTips.count
        let completedActionItems = financeService.tipProgress.values.reduce(0) { $0 + $1.completedActionItems.count }
        
        return (totalTips, readTips, bookmarkedTips, completedActionItems)
    }
    
    func getProgressPercentage() -> Double {
        let stats = getReadingStats()
        guard stats.totalTips > 0 else { return 0 }
        return Double(stats.readTips) / Double(stats.totalTips) * 100
    }
    
    // Featured tips (could be based on user progress, trending, etc.)
    func getFeaturedTips() -> [FinancialTip] {
        // For now, return a mix of beginner tips and popular categories
        let beginnerTips = tips.filter { $0.difficulty == .beginner }
        let budgetingTips = tips.filter { $0.category == .budgeting }
        let savingTips = tips.filter { $0.category == .saving }
        
        var featured: [FinancialTip] = []
        
        // Add one from each category if available
        if let budgetingTip = budgetingTips.first {
            featured.append(budgetingTip)
        }
        if let savingTip = savingTips.first {
            featured.append(savingTip)
        }
        
        // Fill remaining slots with beginner tips
        let remaining = beginnerTips.filter { tip in !featured.contains { $0.id == tip.id } }
        featured.append(contentsOf: remaining.prefix(3 - featured.count))
        
        return featured
    }
    
    // Recommendations based on user activity
    func getRecommendedTips() -> [FinancialTip] {
        let readTipIds = Set(financeService.tipProgress.compactMap { $0.value.isRead ? $0.key : nil })
        let unreadTips = tips.filter { !readTipIds.contains($0.id) }
        
        // Recommend based on categories of read tips
        let readTips = tips.filter { readTipIds.contains($0.id) }
        let readCategories = Set(readTips.map { $0.category })
        
        // Prioritize unread tips in categories the user has shown interest in
        let categoryMatches = unreadTips.filter { readCategories.contains($0.category) }
        let others = unreadTips.filter { !readCategories.contains($0.category) }
        
        return Array((categoryMatches + others).prefix(5))
    }
}
