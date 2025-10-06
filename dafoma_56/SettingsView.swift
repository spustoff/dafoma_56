//
//  SettingsView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    profileSection
                    statsSection
                    dataSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
        .alert("Delete Account", isPresented: $viewModel.showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAccount()
            }
        } message: {
            Text("This will permanently delete all your data and progress. This action cannot be undone.")
        }
        .alert("Reset Data", isPresented: $viewModel.showingResetDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
            }
        } message: {
            Text("This will reset all your progress and preferences. This action cannot be undone.")
        }
        .sheet(isPresented: $viewModel.showingAboutSheet) {
            AboutView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingPrivacySheet) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $viewModel.showingTermsSheet) {
            TermsOfServiceView()
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            // App Icon and Name
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.appAccent.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.appAccent)
                }
                
                VStack(spacing: 4) {
                    Text("QuizFi Total")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Financial Education Made Fun")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.appAccent)
                
                Text("Your Progress")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            let stats = viewModel.getUserStats()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Quizzes",
                    value: "\(stats.totalQuizzesCompleted)",
                    color: .budgetingBlue
                )
                
                StatCard(
                    title: "Puzzles",
                    value: "\(stats.totalPuzzlesCompleted)",
                    color: .investingGreen
                )
                
                StatCard(
                    title: "Tips Read",
                    value: "\(stats.totalTipsRead)",
                    color: .savingsYellow
                )
                
                StatCard(
                    title: "Actions Done",
                    value: "\(stats.totalActionItemsCompleted)",
                    color: .successGreen
                )
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Total Time Spent")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(TimeFormatter.formatDuration(stats.totalTimeSpent))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.appAccent)
                }
                
                HStack {
                    Text("Engagement Score")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(String(format: "%.0f", stats.overallEngagement))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.appAccent)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.appAccent)
                
                Text("Preferences")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Daily reminders and updates"
                ) {
                    Toggle("", isOn: $viewModel.notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                }
                
                SettingsRow(
                    icon: "speaker.wave.2.fill",
                    title: "Sound Effects",
                    subtitle: "Audio feedback for interactions"
                ) {
                    Toggle("", isOn: $viewModel.soundEffectsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                }
                
                SettingsRow(
                    icon: "iphone.radiowaves.left.and.right",
                    title: "Haptic Feedback",
                    subtitle: "Vibration for touch responses"
                ) {
                    Toggle("", isOn: $viewModel.hapticFeedbackEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                }
                
                SettingsRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Always use dark theme"
                ) {
                    Toggle("", isOn: $viewModel.darkModeEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: .appAccent))
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var dataSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "externaldrive.fill")
                    .foregroundColor(.appAccent)
                
                Text("Data Management")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsButton(
                    icon: "square.and.arrow.up",
                    title: "Export Data",
                    subtitle: "Download your progress data",
                    color: .infoBlue
                ) {
                    let data = viewModel.exportUserData()
                    // In a real app, you'd present a share sheet here
                    HapticManager.success()
                }
                
                SettingsButton(
                    icon: "arrow.clockwise",
                    title: "Reset Progress",
                    subtitle: "Clear all quiz and puzzle data",
                    color: .warningOrange
                ) {
                    viewModel.showingResetDataAlert = true
                }
                
                SettingsButton(
                    icon: "trash.fill",
                    title: "Delete Account",
                    subtitle: "Permanently remove all data",
                    color: .errorRed
                ) {
                    viewModel.showingDeleteAccountAlert = true
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.appAccent)
                
                Text("About")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                SettingsButton(
                    icon: "star.fill",
                    title: "Rate App",
                    subtitle: "Leave a review on the App Store",
                    color: .appAccent
                ) {
                    viewModel.rateApp()
                }
                
                SettingsButton(
                    icon: "square.and.arrow.up",
                    title: "Share App",
                    subtitle: "Tell friends about QuizFi Total",
                    color: .successGreen
                ) {
                    viewModel.shareApp()
                }
                
                SettingsButton(
                    icon: "envelope.fill",
                    title: "Contact Support",
                    subtitle: "Get help or report issues",
                    color: .infoBlue
                ) {
                    viewModel.contactSupport()
                }
                
                SettingsButton(
                    icon: "doc.text.fill",
                    title: "Privacy Policy",
                    subtitle: "How we handle your data",
                    color: .textSecondary
                ) {
                    viewModel.openPrivacyPolicy()
                }
                
                SettingsButton(
                    icon: "doc.plaintext.fill",
                    title: "Terms of Service",
                    subtitle: "App usage terms and conditions",
                    color: .textSecondary
                ) {
                    viewModel.openTermsOfService()
                }
                
                SettingsButton(
                    icon: "questionmark.circle.fill",
                    title: "About QuizFi Total",
                    subtitle: "App info and version details",
                    color: .textSecondary
                ) {
                    viewModel.openAbout()
                }
            }
            
            // Version info
            VStack(spacing: 4) {
                Text("Version \(viewModel.appVersion) (\(viewModel.buildNumber))")
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                
                Text("Made with ❤️ for financial education")
                    .font(.caption2)
                    .foregroundColor(.textTertiary)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let content: () -> Content
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appAccent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 4)
    }
}

struct SettingsButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
                    .font(.caption)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // App Icon and Info
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.appAccent.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.appAccent)
                        }
                        
                        VStack(spacing: 8) {
                            Text("QuizFi Total")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            Text("Version \(viewModel.appVersion)")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            
                            Text("Financial Education Made Fun")
                                .font(.body)
                                .foregroundColor(.appAccent)
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About QuizFi Total")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text("""
                        QuizFi Total is an innovative iOS app that combines the thrill of quizzes and puzzles with comprehensive financial literacy education. Our mission is to make learning about personal finance engaging, interactive, and accessible to everyone.
                        
                        Features:
                        • Interactive quizzes on various financial topics
                        • Real-world financial puzzles and scenarios
                        • Comprehensive tips and educational content
                        • Progress tracking and performance analytics
                        • Beautiful, modern interface following Apple Design Guidelines
                        
                        Whether you're just starting your financial journey or looking to expand your knowledge, QuizFi Total provides the tools and content you need to build confidence in managing your money.
                        """)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    
                    // Credits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Credits")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text("""
                        Developed with ❤️ using SwiftUI and following Apple Human Interface Guidelines.
                        
                        Special thanks to the financial education community for inspiring this project.
                        """)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    Privacy Policy
                    
                    Last updated: October 6, 2025
                    
                    Your Privacy Matters
                    
                    QuizFi Total is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app.
                    
                    Information We Collect
                    
                    • Quiz and puzzle progress data
                    • Reading progress for financial tips
                    • App usage statistics and preferences
                    • Device information for app optimization
                    
                    How We Use Your Information
                    
                    • To provide and improve our educational content
                    • To track your learning progress
                    • To personalize your experience
                    • To analyze app performance and usage patterns
                    
                    Data Storage
                    
                    All your data is stored locally on your device. We do not collect or transmit personal information to external servers.
                    
                    Your Rights
                    
                    • You can export your data at any time
                    • You can reset your progress and data
                    • You can delete your account and all associated data
                    
                    Contact Us
                    
                    If you have any questions about this Privacy Policy, please contact us through the app's support feature.
                    """)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineLimit(nil)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Terms of Service View
struct TermsOfServiceView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("""
                    Terms of Service
                    
                    Last updated: October 6, 2025
                    
                    Agreement to Terms
                    
                    By using QuizFi Total, you agree to these Terms of Service. If you do not agree, please do not use the app.
                    
                    Educational Purpose
                    
                    QuizFi Total is designed for educational purposes only. The financial information provided should not be considered as professional financial advice.
                    
                    User Responsibilities
                    
                    • Use the app for educational purposes
                    • Do not attempt to reverse engineer or modify the app
                    • Respect intellectual property rights
                    • Provide feedback to help improve the app
                    
                    Content Accuracy
                    
                    While we strive to provide accurate and up-to-date financial information, we cannot guarantee the completeness or accuracy of all content.
                    
                    Limitation of Liability
                    
                    QuizFi Total and its developers are not liable for any financial decisions made based on the app's content.
                    
                    Changes to Terms
                    
                    We may update these terms from time to time. Continued use of the app constitutes acceptance of any changes.
                    
                    Contact Information
                    
                    For questions about these Terms of Service, please contact us through the app's support feature.
                    """)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                        .lineLimit(nil)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Terms of Service")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    SettingsView()
}
