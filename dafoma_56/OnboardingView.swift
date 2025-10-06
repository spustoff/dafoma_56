//
//  OnboardingView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var showingWelcome = true
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to QuizFi Total",
            subtitle: "Learn Finance Through Fun",
            description: "Master financial literacy with engaging quizzes, challenging puzzles, and expert tips.",
            imageName: "graduationcap.fill",
            color: .appAccent
        ),
        OnboardingPage(
            title: "Interactive Quizzes",
            subtitle: "Test Your Knowledge",
            description: "Take quizzes on budgeting, investing, saving, and more. Track your progress and improve your financial IQ.",
            imageName: "questionmark.circle.fill",
            color: .budgetingBlue
        ),
        OnboardingPage(
            title: "Financial Puzzles",
            subtitle: "Solve Real Scenarios",
            description: "Challenge yourself with real-world financial puzzles. Learn by solving practical money problems.",
            imageName: "puzzlepiece.fill",
            color: .investingGreen
        ),
        OnboardingPage(
            title: "Expert Tips",
            subtitle: "Learn From the Best",
            description: "Access comprehensive financial tips and actionable advice to improve your money management skills.",
            imageName: "lightbulb.fill",
            color: .savingsYellow
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.appBackground, Color.appSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if showingWelcome {
                    welcomeAnimation
                        .transition(.opacity.combined(with: .scale))
                } else {
                    onboardingContent
                        .transition(.opacity.combined(with: .slide))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.smooth.delay(0.5)) {
                    showingWelcome = false
                }
            }
        }
    }
    
    private var welcomeAnimation: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon Animation
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .pulseEffect()
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appAccent)
            }
            
            VStack(spacing: 16) {
                Text("QuizFi Total")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text("Financial Education Made Fun")
                    .font(.title3)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var onboardingContent: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Bottom Controls
            VStack(spacing: 24) {
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.appAccent : Color.textTertiary)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                
                // Navigation Buttons
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.smooth) {
                                currentPage -= 1
                            }
                        }
                        .secondaryButtonStyle()
                    }
                    
                    Spacer()
                    
                    Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                        if currentPage == pages.count - 1 {
                            completeOnboarding()
                        } else {
                            withAnimation(.smooth) {
                                currentPage += 1
                            }
                        }
                    }
                    .primaryButtonStyle()
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.smooth) {
            hasCompletedOnboarding = true
        }
        HapticManager.success()
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}
