//
//  Helpers.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation
import SwiftUI

// MARK: - Time Formatting
struct TimeFormatter {
    static func formatDuration(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "0:%02d", seconds)
        }
    }
    
    static func formatEstimatedTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes) min"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }
    
    static func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Score Formatting
struct ScoreFormatter {
    static func formatPercentage(_ percentage: Double) -> String {
        return String(format: "%.0f%%", percentage)
    }
    
    static func formatScore(_ score: Int, total: Int) -> String {
        return "\(score)/\(total)"
    }
    
    static func getGradeEmoji(_ grade: String) -> String {
        switch grade {
        case "A+": return "🏆"
        case "A": return "🥇"
        case "B": return "🥈"
        case "C": return "🥉"
        case "D": return "📚"
        case "F": return "💪"
        default: return "📊"
        }
    }
    
    static func getPerformanceMessage(_ percentage: Double) -> String {
        switch percentage {
        case 95...100: return "Perfect! Outstanding work!"
        case 90..<95: return "Excellent! You're a financial genius!"
        case 80..<90: return "Great job! You really know your stuff!"
        case 70..<80: return "Good work! Keep learning and improving!"
        case 60..<70: return "Not bad! There's room for improvement."
        case 50..<60: return "Keep studying! You're getting there."
        default: return "Don't give up! Practice makes perfect."
        }
    }
}

// MARK: - Haptic Feedback
struct HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
    }
    
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(type)
    }
    
    static func selection() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // Convenience methods
    static func success() {
        notification(.success)
    }
    
    static func error() {
        notification(.error)
    }
    
    static func warning() {
        notification(.warning)
    }
    
    static func lightImpact() {
        impact(.light)
    }
    
    static func mediumImpact() {
        impact(.medium)
    }
    
    static func heavyImpact() {
        impact(.heavy)
    }
}

// MARK: - Animation Helpers
struct AnimationHelper {
    static let bouncy = Animation.interpolatingSpring(stiffness: 300, damping: 15)
    static let smooth = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.15)
    static let slow = Animation.easeInOut(duration: 0.6)
    
    static func delay(_ delay: Double) -> Animation {
        return Animation.easeInOut(duration: 0.3).delay(delay)
    }
    
    static func spring(response: Double = 0.5, dampingFraction: Double = 0.8) -> Animation {
        return Animation.interpolatingSpring(mass: 1, stiffness: 1/response, damping: dampingFraction * 2 * sqrt(1/response))
    }
}

// MARK: - Device Info
struct DeviceInfo {
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    static var isSmallScreen: Bool {
        screenWidth <= 375 // iPhone SE, iPhone 12 mini
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return UIEdgeInsets.zero
    }
}

// MARK: - UserDefaults Helpers
extension UserDefaults {
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            set(data, forKey: key)
        }
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Array Extensions
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array where Element: Identifiable {
    func firstIndex(of element: Element) -> Int? {
        return firstIndex { $0.id == element.id }
    }
}

// MARK: - String Extensions
extension String {
    func truncated(to length: Int, trailing: String = "...") -> String {
        if self.count <= length {
            return self
        } else {
            return String(self.prefix(length)) + trailing
        }
    }
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    func matches(_ regex: String) -> Bool {
        return range(of: regex, options: .regularExpression) != nil
    }
}

// MARK: - Double Extensions
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var asPercentage: String {
        return String(format: "%.1f%%", self)
    }
}

// MARK: - Date Extensions
extension Date {
    func timeAgo() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}

// MARK: - Color Helpers
extension Color {
    func lighter(by percentage: Double = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
    
    func darker(by percentage: Double = 0.2) -> Color {
        // This is a simplified version - in a real app you might want more sophisticated color manipulation
        return self.opacity(1.0 + percentage)
    }
}

// MARK: - View Helpers
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Custom Shapes for Specific Corner Radius
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Network Helpers (for future use)
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    
    // Simplified network monitoring - in a real app you'd use Network framework
    init() {
        // Implementation would go here
    }
}

// MARK: - Validation Helpers
struct Validator {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return email.matches(emailRegex)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        return password.count >= 8
    }
    
    static func isValidAmount(_ amount: String) -> Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }
}
