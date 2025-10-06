//
//  SettingsViewModel.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var showingDeleteAccountAlert = false
    @Published var showingResetDataAlert = false
    @Published var showingAboutSheet = false
    @Published var showingPrivacySheet = false
    @Published var showingTermsSheet = false
    
    // User preferences
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("soundEffectsEnabled") var soundEffectsEnabled = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled = true
    @AppStorage("darkModeEnabled") var darkModeEnabled = true
    @AppStorage("dailyReminderTime") var dailyReminderTimeInterval: Double = Date().timeIntervalSince1970
    
    var dailyReminderTime: Date {
        get { Date(timeIntervalSince1970: dailyReminderTimeInterval) }
        set { dailyReminderTimeInterval = newValue.timeIntervalSince1970 }
    }
    @AppStorage("preferredDifficulty") var preferredDifficulty = "beginner"
    
    // App info
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    func deleteAccount() {
        // Clear all user data
        resetAllData()
        
        // Reset onboarding
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        HapticManager.success()
    }
    
    func resetAllData() {
        // Clear quiz data
        UserDefaults.standard.removeObject(forKey: "completedQuizzes")
        
        // Clear puzzle data
        UserDefaults.standard.removeObject(forKey: "puzzleProgress")
        UserDefaults.standard.removeObject(forKey: "completedPuzzles")
        
        // Clear finance tips data
        UserDefaults.standard.removeObject(forKey: "tipProgress")
        UserDefaults.standard.removeObject(forKey: "bookmarkedTips")
        
        // Reset preferences to defaults
        notificationsEnabled = true
        soundEffectsEnabled = true
        hapticFeedbackEnabled = true
        darkModeEnabled = true
        preferredDifficulty = "beginner"
        
        HapticManager.success()
    }
    
    func exportUserData() -> String {
        var exportData: [String: Any] = [:]
        
        // Export quiz results
        if let quizData = UserDefaults.standard.data(forKey: "completedQuizzes") {
            exportData["completedQuizzes"] = quizData.base64EncodedString()
        }
        
        // Export puzzle progress
        if let puzzleData = UserDefaults.standard.data(forKey: "puzzleProgress") {
            exportData["puzzleProgress"] = puzzleData.base64EncodedString()
        }
        
        if let completedPuzzleData = UserDefaults.standard.data(forKey: "completedPuzzles") {
            exportData["completedPuzzles"] = completedPuzzleData.base64EncodedString()
        }
        
        // Export finance tips progress
        if let tipData = UserDefaults.standard.data(forKey: "tipProgress") {
            exportData["tipProgress"] = tipData.base64EncodedString()
        }
        
        if let bookmarkData = UserDefaults.standard.data(forKey: "bookmarkedTips") {
            exportData["bookmarkedTips"] = bookmarkData.base64EncodedString()
        }
        
        // Export preferences
        exportData["preferences"] = [
            "notificationsEnabled": notificationsEnabled,
            "soundEffectsEnabled": soundEffectsEnabled,
            "hapticFeedbackEnabled": hapticFeedbackEnabled,
            "darkModeEnabled": darkModeEnabled,
            "preferredDifficulty": preferredDifficulty
        ]
        
        // Convert to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "Error exporting data"
    }
    
    func getUserStats() -> UserStats {
        let quizService = QuizService.shared
        let puzzleService = PuzzleService.shared
        let financeService = FinanceTipService.shared
        
        let quizStats = quizService.getUserStats()
        let puzzleStats = puzzleService.getUserPuzzleStats()
        
        let totalTipsRead = financeService.tipProgress.values.filter { $0.isRead }.count
        let totalBookmarks = financeService.bookmarkedTips.count
        let totalActionItems = financeService.tipProgress.values.reduce(0) { $0 + $1.completedActionItems.count }
        
        return UserStats(
            totalQuizzesCompleted: quizStats.totalQuizzes,
            averageQuizScore: quizStats.averageScore,
            totalQuizTime: quizStats.totalTime,
            totalPuzzlesCompleted: puzzleStats.completed,
            averagePuzzleScore: puzzleStats.averageScore,
            totalPuzzleTime: puzzleStats.totalTime,
            totalTipsRead: totalTipsRead,
            totalBookmarks: totalBookmarks,
            totalActionItemsCompleted: totalActionItems
        )
    }
    
    func shareApp() {
        // This would typically open the share sheet
        // For now, we'll just provide the text to share
    }
    
    func rateApp() {
        // This would typically open the App Store rating page
        // For now, we'll just trigger haptic feedback
        HapticManager.success()
    }
    
    func contactSupport() {
        // This would typically open mail app or support form
        // For now, we'll just trigger haptic feedback
        HapticManager.lightImpact()
    }
    
    func openPrivacyPolicy() {
        showingPrivacySheet = true
    }
    
    func openTermsOfService() {
        showingTermsSheet = true
    }
    
    func openAbout() {
        showingAboutSheet = true
    }
}

struct UserStats {
    let totalQuizzesCompleted: Int
    let averageQuizScore: Double
    let totalQuizTime: TimeInterval
    let totalPuzzlesCompleted: Int
    let averagePuzzleScore: Double
    let totalPuzzleTime: TimeInterval
    let totalTipsRead: Int
    let totalBookmarks: Int
    let totalActionItemsCompleted: Int
    
    var totalTimeSpent: TimeInterval {
        return totalQuizTime + totalPuzzleTime
    }
    
    var overallEngagement: Double {
        let quizEngagement = Double(totalQuizzesCompleted) * 0.3
        let puzzleEngagement = Double(totalPuzzlesCompleted) * 0.3
        let tipsEngagement = Double(totalTipsRead) * 0.2
        let actionEngagement = Double(totalActionItemsCompleted) * 0.2
        
        return quizEngagement + puzzleEngagement + tipsEngagement + actionEngagement
    }
}
