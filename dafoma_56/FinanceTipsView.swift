//
//  FinanceTipsView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct FinanceTipsView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @State private var showingTipDetail = false
    @State private var selectedTip: FinancialTip?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerView
                        searchAndFiltersView
                        
                        if viewModel.showingBookmarksOnly {
                            bookmarksSection
                        } else {
                            featuredSection
                            categoriesSection
                        }
                        
                        tipsSection
                    }
                    .padding()
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle("Financial Tips")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingTipDetail) {
            if let tip = selectedTip {
                TipDetailView(tip: tip, viewModel: viewModel)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Learn & Grow")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Expert financial advice at your fingertips")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Button(viewModel.showingBookmarksOnly ? "All Tips" : "Bookmarks") {
                    viewModel.toggleBookmarksOnly()
                }
                .primaryButtonStyle()
            }
            
            // Reading Progress
            let stats = viewModel.getReadingStats()
            let progress = viewModel.getProgressPercentage()
            
            VStack(spacing: 8) {
                HStack {
                    Text("Reading Progress")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    Text("\(Int(progress))%")
                        .font(.headline)
                        .foregroundColor(.appAccent)
                }
                
                ProgressView(value: progress / 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .appAccent))
                    .scaleEffect(y: 2)
                
                HStack(spacing: 20) {
                    StatCard(title: "Read", value: "\(stats.readTips)", color: .successGreen)
                    StatCard(title: "Bookmarked", value: "\(stats.bookmarkedTips)", color: .appAccent)
                    StatCard(title: "Actions Done", value: "\(stats.completedActionItems)", color: .infoBlue)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, 4)
    }
    
    private var searchAndFiltersView: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textTertiary)
                
                TextField("Search tips...", text: $viewModel.searchText)
                    .foregroundColor(.textPrimary)
                    .onChange(of: viewModel.searchText) { newValue in
                        viewModel.updateSearchText(newValue)
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button("Clear") {
                        viewModel.updateSearchText("")
                    }
                    .font(.caption)
                    .foregroundColor(.appAccent)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Categories",
                        isSelected: viewModel.selectedCategory == nil,
                        color: .appAccent
                    ) {
                        viewModel.setCategory(nil)
                    }
                    
                    ForEach(FinancialTip.TipCategory.allCases, id: \.self) { category in
                        FilterChip(
                            title: category.rawValue,
                            isSelected: viewModel.selectedCategory == category,
                            color: getCategoryColor(category.rawValue)
                        ) {
                            viewModel.setCategory(viewModel.selectedCategory == category ? nil : category)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Difficulty filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterChip(
                        title: "All Levels",
                        isSelected: viewModel.selectedDifficulty == nil,
                        color: .appAccent
                    ) {
                        viewModel.setDifficulty(nil)
                    }
                    
                    ForEach(FinancialTip.Difficulty.allCases, id: \.self) { difficulty in
                        FilterChip(
                            title: difficulty.rawValue,
                            isSelected: viewModel.selectedDifficulty == difficulty,
                            color: getDifficultyColor(difficulty.rawValue)
                        ) {
                            viewModel.setDifficulty(viewModel.selectedDifficulty == difficulty ? nil : difficulty)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            if viewModel.selectedCategory != nil || viewModel.selectedDifficulty != nil || !viewModel.searchText.isEmpty {
                Button("Clear All Filters") {
                    viewModel.clearFilters()
                }
                .font(.caption)
                .foregroundColor(.errorRed)
            }
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Featured Tips")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.getFeaturedTips(), id: \.id) { tip in
                        FeaturedTipCard(tip: tip) {
                            openTip(tip)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(FinancialTip.TipCategory.allCases.prefix(6), id: \.self) { category in
                    CategoryTipCard(category: category) {
                        viewModel.setCategory(category)
                    }
                }
            }
        }
    }
    
    private var bookmarksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bookmarked Tips")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            if viewModel.getBookmarkedTips().isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.textTertiary)
                    
                    Text("No bookmarked tips yet")
                        .font(.headline)
                        .foregroundColor(.textSecondary)
                    
                    Text("Bookmark tips you want to read later by tapping the bookmark icon")
                        .font(.body)
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .background(Color.cardBackground)
                .cornerRadius(16)
            }
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.showingBookmarksOnly ? "Bookmarked Tips" : "All Tips")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.filteredTips.count) tips")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredTips, id: \.id) { tip in
                    TipCard(tip: tip, viewModel: viewModel) {
                        openTip(tip)
                    }
                }
            }
        }
    }
    
    private func openTip(_ tip: FinancialTip) {
        selectedTip = tip
        showingTipDetail = true
        viewModel.markTipAsRead(tip.id)
        HapticManager.lightImpact()
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "saving":
            return .savingsYellow
        case "investing":
            return .investingGreen
        case "credit management":
            return .creditOrange
        case "debt reduction":
            return .errorRed
        case "emergency fund":
            return .successGreen
        case "retirement":
            return .insurancePurple
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "real estate":
            return .generalTeal
        case "side hustle":
            return .warningOrange
        case "financial mindset":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner":
            return .beginnerGreen
        case "intermediate":
            return .intermediateOrange
        case "advanced":
            return .advancedRed
        default:
            return .appAccent
        }
    }
}

struct FeaturedTipCard: View {
    let tip: FinancialTip
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text(tip.category.rawValue)
                    .font(.caption)
                    .foregroundColor(getCategoryColor(tip.category.rawValue))
                
                HStack {
                    Label("\(tip.readingTime) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(tip.difficulty.rawValue)
                        .font(.caption2)
                        .foregroundColor(getDifficultyColor(tip.difficulty.rawValue))
                }
            }
            .padding()
            .frame(width: 200, height: 100)
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "saving":
            return .savingsYellow
        case "investing":
            return .investingGreen
        case "credit management":
            return .creditOrange
        case "debt reduction":
            return .errorRed
        case "emergency fund":
            return .successGreen
        case "retirement":
            return .insurancePurple
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "real estate":
            return .generalTeal
        case "side hustle":
            return .warningOrange
        case "financial mindset":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner":
            return .beginnerGreen
        case "intermediate":
            return .intermediateOrange
        case "advanced":
            return .advancedRed
        default:
            return .appAccent
        }
    }
}

struct CategoryTipCard: View {
    let category: FinancialTip.TipCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: categoryIcon)
                    .font(.title3)
                    .foregroundColor(getCategoryColor(category.rawValue))
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.cardBackground)
            .cornerRadius(8)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "saving":
            return .savingsYellow
        case "investing":
            return .investingGreen
        case "credit management":
            return .creditOrange
        case "debt reduction":
            return .errorRed
        case "emergency fund":
            return .successGreen
        case "retirement":
            return .insurancePurple
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "real estate":
            return .generalTeal
        case "side hustle":
            return .warningOrange
        case "financial mindset":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private var categoryIcon: String {
        switch category {
        case .budgeting: return "chart.pie.fill"
        case .saving: return "banknote.fill"
        case .investing: return "chart.line.uptrend.xyaxis"
        case .creditManagement: return "creditcard.fill"
        case .debtReduction: return "minus.circle.fill"
        case .emergencyFund: return "shield.fill"
        case .retirement: return "figure.walk"
        case .insurance: return "umbrella.fill"
        case .taxes: return "doc.text.fill"
        case .realEstate: return "house.fill"
        case .sideHustle: return "briefcase.fill"
        case .mindset: return "brain.head.profile"
        }
    }
}

struct TipCard: View {
    let tip: FinancialTip
    @ObservedObject var viewModel: FinanceViewModel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(tip.title)
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleBookmark(tip.id)
                            HapticManager.lightImpact()
                        }) {
                            Image(systemName: viewModel.isBookmarked(tip.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.appAccent)
                        }
                    }
                    
                    HStack {
                    Text(tip.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(getCategoryColor(tip.category.rawValue))
                        
                        Spacer()
                        
                        Text(tip.difficulty.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(getDifficultyColor(tip.difficulty.rawValue))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(getDifficultyColor(tip.difficulty.rawValue).opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    HStack {
                        Label("\(tip.readingTime) min read", systemImage: "clock")
                        
                        Spacer()
                        
                        if let progress = viewModel.getProgress(for: tip.id), progress.isRead {
                            Label("Read", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category.lowercased() {
        case "budgeting":
            return .budgetingBlue
        case "saving":
            return .savingsYellow
        case "investing":
            return .investingGreen
        case "credit management":
            return .creditOrange
        case "debt reduction":
            return .errorRed
        case "emergency fund":
            return .successGreen
        case "retirement":
            return .insurancePurple
        case "insurance":
            return .insurancePurple
        case "taxes", "tax planning":
            return .taxesRed
        case "real estate":
            return .generalTeal
        case "side hustle":
            return .warningOrange
        case "financial mindset":
            return .entertainmentPink
        default:
            return .appAccent
        }
    }
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner":
            return .beginnerGreen
        case "intermediate":
            return .intermediateOrange
        case "advanced":
            return .advancedRed
        default:
            return .appAccent
        }
    }
}

#Preview {
    FinanceTipsView()
}
