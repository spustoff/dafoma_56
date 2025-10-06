//
//  ColorExtensions.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

extension Color {
    // App Color Scheme
    static let appBackground = Color(hex: "161439")
    static let appAccent = Color(hex: "E9C24C")
    static let appSecondary = Color(hex: "2A2550")
    static let appTertiary = Color(hex: "3D3A6B")
    
    // Semantic Colors
    static let cardBackground = Color(hex: "1E1B42")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "B8B5D1")
    static let textTertiary = Color(hex: "8B88A3")
    
    // Status Colors
    static let successGreen = Color(hex: "4CAF50")
    static let errorRed = Color(hex: "F44336")
    static let warningOrange = Color(hex: "FF9800")
    static let infoBlue = Color(hex: "2196F3")
    
    // Difficulty Colors
    static let beginnerGreen = Color(hex: "4CAF50")
    static let intermediateOrange = Color(hex: "FF9800")
    static let advancedRed = Color(hex: "F44336")
    static let expertPurple = Color(hex: "9C27B0")
    
    // Category Colors
    static let budgetingBlue = Color(hex: "2196F3")
    static let investingGreen = Color(hex: "4CAF50")
    static let savingsYellow = Color(hex: "FFC107")
    static let creditOrange = Color(hex: "FF9800")
    static let insurancePurple = Color(hex: "9C27B0")
    static let taxesRed = Color(hex: "F44336")
    static let generalTeal = Color(hex: "009688")
    static let entertainmentPink = Color(hex: "E91E63")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct PrimaryButtonStyle: ViewModifier {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isEnabled ? Color.appBackground : Color.textTertiary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isEnabled ? Color.appAccent : Color.appSecondary)
            .cornerRadius(25)
            .shadow(color: isEnabled ? Color.appAccent.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
            .scaleEffect(isEnabled ? 1.0 : 0.95)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

struct SecondaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color.appAccent)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.appAccent, lineWidth: 2)
            )
    }
}

struct GlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButtonStyle() -> some View {
        modifier(SecondaryButtonStyle())
    }
    
    func glassEffect() -> some View {
        modifier(GlassEffect())
    }
    
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
    
    func difficultyColor(for difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner", "easy":
            return .beginnerGreen
        case "intermediate", "medium":
            return .intermediateOrange
        case "advanced", "hard":
            return .advancedRed
        case "expert":
            return .expertPurple
        default:
            return .appAccent
        }
    }
    
    func categoryColor(for category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "investing":
            return .investingGreen
        case "savings", "saving":
            return .savingsYellow
        case "credit & debt", "credit management", "creditmanagement":
            return .creditOrange
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "general finance", "generalfinance":
            return .generalTeal
        case "entertainment":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
}

// MARK: - Custom Shapes
struct WaveShape: Shape {
    var animatableData: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight = height * 0.1
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 2 + animatableData)
            let y = height - waveHeight - sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    init(progress: Double, color: Color = .appAccent, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
    }
}
