//
//  TipDetailView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct TipDetailView: View {
    let tip: FinancialTip
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    contentSection
                    keyTakeawaysSection
                    actionItemsSection
                    relatedTopicsSection
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    viewModel.toggleBookmark(tip.id)
                    HapticManager.lightImpact()
                }) {
                    Image(systemName: viewModel.isBookmarked(tip.id) ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.appAccent)
                }
            )
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.markTipAsRead(tip.id)
        }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
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
    
    private func getDifficultyColor(_ difficulty: String) -> Color {
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
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(tip.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
                .lineLimit(nil)
            
            HStack {
                Text(tip.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(getCategoryColor(tip.category.rawValue))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(getCategoryColor(tip.category.rawValue).opacity(0.2))
                    .cornerRadius(12)
                
                Spacer()
                
                Text(tip.difficulty.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(getDifficultyColor(tip.difficulty.rawValue))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(getDifficultyColor(tip.difficulty.rawValue).opacity(0.2))
                    .cornerRadius(12)
            }
            
            HStack(spacing: 20) {
                Label("\(tip.readingTime) min read", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                Label("\(tip.actionItems.count) action items", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                
                if let progress = viewModel.getProgress(for: tip.id), progress.isRead {
                    Label("Read", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.successGreen)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Content")
                .font(.headline)
                .foregroundColor(.textPrimary)
            
            Text(tip.content)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var keyTakeawaysSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "key.fill")
                    .foregroundColor(.appAccent)
                
                Text("Key Takeaways")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(tip.keyTakeaways.enumerated()), id: \.offset) { index, takeaway in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.appAccent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 8)
                        
                        Text(takeaway)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var actionItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.successGreen)
                
                Text("Action Items")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if let progress = viewModel.getProgress(for: tip.id) {
                    Text("\(progress.completedActionItems.count)/\(tip.actionItems.count)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(Array(tip.actionItems.enumerated()), id: \.offset) { index, item in
                    ActionItemRow(
                        item: item,
                        index: index,
                        isCompleted: viewModel.getProgress(for: tip.id)?.completedActionItems.contains(index) ?? false
                    ) { isCompleted in
                        if isCompleted {
                            viewModel.completeActionItem(tip.id, itemIndex: index)
                        } else {
                            viewModel.uncompleteActionItem(tip.id, itemIndex: index)
                        }
                        HapticManager.lightImpact()
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
    
    private var relatedTopicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.infoBlue)
                
                Text("Related Topics")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(tip.relatedTopics, id: \.self) { topic in
                    Text(topic)
                        .font(.caption)
                        .foregroundColor(.infoBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.infoBlue.opacity(0.2))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct ActionItemRow: View {
    let item: String
    let index: Int
    let isCompleted: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                onToggle(!isCompleted)
            }) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? .successGreen : .textTertiary)
                    .font(.title3)
            }
            
            Text(item)
                .font(.body)
                .foregroundColor(isCompleted ? .textTertiary : .textSecondary)
                .strikethrough(isCompleted)
                .lineLimit(nil)
            
            Spacer()
        }
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}

#Preview {
    TipDetailView(
        tip: FinancialTip(
            title: "Sample Tip",
            category: .budgeting,
            content: "Sample content",
            keyTakeaways: ["Key 1", "Key 2"],
            actionItems: ["Action 1", "Action 2"],
            difficulty: .beginner,
            readingTime: 5,
            tags: [],
            relatedTopics: []
        ),
        viewModel: FinanceViewModel()
    )
}
