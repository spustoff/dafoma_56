//
//  FinanceTipService.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import Foundation

class FinanceTipService: ObservableObject {
    static let shared = FinanceTipService()
    
    @Published var tips: [FinancialTip] = []
    @Published var tipProgress: [UUID: TipProgress] = [:]
    @Published var bookmarkedTips: Set<UUID> = []
    
    private init() {
        loadTips()
        loadTipProgress()
        loadBookmarkedTips()
    }
    
    private func loadTips() {
        tips = [
            // Budgeting Tips
            FinancialTip(
                title: "Master the 50/30/20 Budget Rule",
                category: .budgeting,
                content: """
                The 50/30/20 rule is one of the most popular and effective budgeting methods. Here's how it works:
                
                **50% for Needs**: These are expenses you can't avoid - rent/mortgage, utilities, groceries, minimum debt payments, insurance, and transportation.
                
                **30% for Wants**: This covers discretionary spending like dining out, entertainment, hobbies, streaming services, and non-essential shopping.
                
                **20% for Savings and Debt Repayment**: This includes emergency fund contributions, retirement savings, extra debt payments, and other financial goals.
                
                **Why It Works:**
                - Simple to understand and implement
                - Flexible enough to adapt to different income levels
                - Ensures you're saving while still enjoying life
                - Provides clear spending boundaries
                
                **Getting Started:**
                1. Calculate your after-tax monthly income
                2. Multiply by 0.50, 0.30, and 0.20 to get your category limits
                3. Track your expenses for a month to see where you currently stand
                4. Adjust your spending to fit the percentages
                
                Remember, these are guidelines. If you have high-interest debt, consider allocating more than 20% to debt repayment temporarily.
                """,
                keyTakeaways: [
                    "50% of income goes to essential needs",
                    "30% can be spent on wants and entertainment",
                    "20% should be saved or used for debt repayment",
                    "Adjust percentages based on your specific situation"
                ],
                actionItems: [
                    "Calculate your after-tax monthly income",
                    "List all your current monthly expenses",
                    "Categorize expenses into needs, wants, and savings",
                    "Compare your current spending to the 50/30/20 targets",
                    "Identify areas where you need to cut back or reallocate",
                    "Set up automatic transfers for your savings portion"
                ],
                difficulty: .beginner,
                readingTime: 5,
                tags: ["budgeting", "money management", "personal finance", "savings"],
                relatedTopics: ["Emergency Fund Basics", "Debt Payoff Strategies", "Automatic Savings"]
            ),
            
            FinancialTip(
                title: "Build Your Emergency Fund: A Step-by-Step Guide",
                category: .emergencyFund,
                content: """
                An emergency fund is your financial safety net - money set aside to cover unexpected expenses or income loss. It's one of the most important financial tools you can have.
                
                **Why You Need an Emergency Fund:**
                - Prevents you from going into debt during emergencies
                - Provides peace of mind and reduces financial stress
                - Gives you flexibility to make better financial decisions
                - Protects your long-term financial goals
                
                **How Much to Save:**
                - **Starter Goal**: $1,000 for basic emergencies
                - **Full Goal**: 3-6 months of living expenses
                - **Extended Goal**: 6-12 months if you have irregular income
                
                **Where to Keep Your Emergency Fund:**
                - High-yield savings account (best option)
                - Money market account
                - Short-term CDs (less liquid but higher returns)
                - NOT in checking accounts or investments
                
                **Building Strategy:**
                1. Start small - even $25/month adds up
                2. Use windfalls (tax refunds, bonuses, gifts)
                3. Automate transfers to make it effortless
                4. Cut one expense temporarily to boost savings
                5. Use the "pay yourself first" principle
                
                **What Counts as an Emergency:**
                ✅ Job loss or reduced income
                ✅ Major medical expenses
                ✅ Essential home repairs
                ✅ Car repairs needed for work
                ✅ Family emergencies
                
                ❌ Vacations, weddings, or planned purchases
                ❌ Regular bills or predictable expenses
                ❌ Investment opportunities
                """,
                keyTakeaways: [
                    "Start with $1,000, then build to 3-6 months of expenses",
                    "Keep funds in a high-yield savings account for easy access",
                    "Only use for true emergencies, not planned expenses",
                    "Automate contributions to build the fund consistently"
                ],
                actionItems: [
                    "Calculate your monthly living expenses",
                    "Set a starter goal of $1,000",
                    "Open a separate high-yield savings account",
                    "Set up automatic monthly transfers",
                    "Identify one expense you can cut to boost savings",
                    "Create clear rules for when to use the fund"
                ],
                difficulty: .beginner,
                readingTime: 7,
                tags: ["emergency fund", "savings", "financial security", "peace of mind"],
                relatedTopics: ["High-Yield Savings Accounts", "Budgeting Basics", "Insurance Planning"]
            ),
            
            // Investing Tips
            FinancialTip(
                title: "Index Fund Investing for Beginners",
                category: .investing,
                content: """
                Index funds are one of the best investment options for beginners and experienced investors alike. They offer instant diversification, low costs, and historically solid returns.
                
                **What Are Index Funds:**
                Index funds are mutual funds or ETFs that track a specific market index (like the S&P 500). Instead of trying to beat the market, they aim to match its performance.
                
                **Benefits of Index Funds:**
                - **Instant Diversification**: One fund can hold hundreds or thousands of stocks
                - **Low Costs**: Expense ratios typically under 0.20%
                - **Consistent Performance**: Match market returns over time
                - **Simple**: No need to research individual stocks
                - **Tax Efficient**: Lower turnover means fewer taxable events
                
                **Popular Index Funds to Consider:**
                - **Total Stock Market Index**: Broadest US stock exposure
                - **S&P 500 Index**: Large US companies
                - **International Index**: Global diversification
                - **Bond Index**: Fixed income for stability
                
                **Getting Started:**
                1. **Choose a Brokerage**: Vanguard, Fidelity, Schwab offer excellent options
                2. **Open an Account**: Start with a taxable account or IRA
                3. **Start Simple**: Begin with a total stock market index fund
                4. **Automate Investing**: Set up regular monthly contributions
                5. **Stay Consistent**: Keep investing regardless of market conditions
                
                **Dollar-Cost Averaging:**
                Instead of trying to time the market, invest the same amount regularly. This strategy:
                - Reduces the impact of market volatility
                - Removes emotion from investing decisions
                - Builds wealth consistently over time
                
                **Common Mistakes to Avoid:**
                - Trying to time the market
                - Checking your account balance too frequently
                - Panicking during market downturns
                - Investing money you'll need within 5 years
                """,
                keyTakeaways: [
                    "Index funds provide instant diversification at low cost",
                    "Dollar-cost averaging reduces timing risk",
                    "Start simple with a total market index fund",
                    "Consistency matters more than perfect timing"
                ],
                actionItems: [
                    "Research low-cost brokerages (Vanguard, Fidelity, Schwab)",
                    "Open an investment account (IRA or taxable)",
                    "Choose your first index fund",
                    "Set up automatic monthly investments",
                    "Commit to not checking balances daily",
                    "Learn about tax-advantaged accounts (401k, IRA)"
                ],
                difficulty: .intermediate,
                readingTime: 8,
                tags: ["investing", "index funds", "diversification", "long-term wealth"],
                relatedTopics: ["401k Optimization", "IRA vs Roth IRA", "Asset Allocation"]
            ),
            
            // Credit Management
            FinancialTip(
                title: "Build and Maintain Excellent Credit",
                category: .creditManagement,
                content: """
                Your credit score affects many aspects of your financial life - from loan interest rates to apartment rentals. Understanding how to build and maintain good credit is essential.
                
                **What Affects Your Credit Score:**
                - **Payment History (35%)**: Pay all bills on time, every time
                - **Credit Utilization (30%)**: Keep balances low relative to limits
                - **Length of Credit History (15%)**: Keep old accounts open
                - **Credit Mix (10%)**: Have different types of credit
                - **New Credit (10%)**: Limit hard inquiries
                
                **Credit Score Ranges:**
                - 800-850: Excellent
                - 740-799: Very Good
                - 670-739: Good
                - 580-669: Fair
                - 300-579: Poor
                
                **Building Credit from Scratch:**
                1. **Secured Credit Card**: Put down a deposit to get started
                2. **Become an Authorized User**: Ask family to add you to their account
                3. **Credit Builder Loan**: Some banks offer these specifically for building credit
                4. **Student Credit Card**: If you're in school, these are easier to qualify for
                
                **Maintaining Excellent Credit:**
                - **Pay on Time**: Set up autopay for at least minimum payments
                - **Keep Utilization Low**: Use less than 30% of available credit, ideally under 10%
                - **Don't Close Old Cards**: Length of history matters
                - **Monitor Your Credit**: Check reports annually for errors
                - **Limit New Applications**: Only apply when necessary
                
                **Quick Credit Improvement Tips:**
                - Pay down existing balances
                - Ask for credit limit increases
                - Pay bills twice per month to keep reported balances low
                - Dispute any errors on your credit report
                - Consider becoming an authorized user on someone else's account
                
                **Credit Monitoring:**
                - Get free reports from annualcreditreport.com
                - Use free monitoring services like Credit Karma
                - Set up alerts for changes to your credit report
                - Check your score regularly but don't obsess over small changes
                """,
                keyTakeaways: [
                    "Payment history is the most important factor (35%)",
                    "Keep credit utilization below 30%, ideally under 10%",
                    "Don't close old credit cards - length of history matters",
                    "Monitor your credit regularly for errors and fraud"
                ],
                actionItems: [
                    "Check your credit score and report",
                    "Set up autopay for all credit cards",
                    "Calculate your current credit utilization",
                    "Pay down high balances if utilization is over 30%",
                    "Set up credit monitoring alerts",
                    "Dispute any errors found on your credit report"
                ],
                difficulty: .intermediate,
                readingTime: 6,
                tags: ["credit score", "credit cards", "financial health", "loans"],
                relatedTopics: ["Debt Payoff Strategies", "Mortgage Preparation", "Identity Protection"]
            ),
            
            // Retirement Planning
            FinancialTip(
                title: "Maximize Your 401(k) Benefits",
                category: .retirement,
                content: """
                Your 401(k) is one of the most powerful tools for building retirement wealth. Understanding how to maximize its benefits can significantly impact your financial future.
                
                **Key 401(k) Benefits:**
                - **Tax Advantages**: Traditional 401(k) reduces current taxable income
                - **Employer Match**: Free money if your employer offers matching
                - **High Contribution Limits**: $23,000 in 2024 ($30,500 if 50+)
                - **Automatic Investing**: Builds wealth through payroll deduction
                - **Compound Growth**: Tax-deferred growth over decades
                
                **Employer Match Strategy:**
                Always contribute enough to get the full employer match - it's an immediate 100% return on your investment. Common match formulas:
                - 50% match up to 6% of salary
                - 100% match up to 3% of salary
                - Dollar-for-dollar up to $1,000 annually
                
                **Contribution Strategy:**
                1. **Start with the Match**: Contribute enough to get full employer match
                2. **Increase Gradually**: Boost contributions by 1% annually
                3. **Use Raises Wisely**: Put half of any raise toward retirement
                4. **Maximize if Possible**: Work toward the annual contribution limit
                
                **Investment Selection:**
                - **Target-Date Funds**: Automatically adjusts allocation as you age
                - **Low-Cost Index Funds**: Broad market exposure with minimal fees
                - **Avoid**: High-fee actively managed funds, company stock concentration
                
                **Roth vs Traditional 401(k):**
                - **Traditional**: Tax deduction now, pay taxes in retirement
                - **Roth**: No deduction now, tax-free withdrawals in retirement
                - **Consider Roth if**: You're young, in a low tax bracket, expect higher future taxes
                
                **Common Mistakes:**
                - Not contributing enough to get full employer match
                - Choosing high-fee investment options
                - Cashing out when changing jobs
                - Not increasing contributions over time
                - Ignoring your account for years
                
                **Job Change Strategy:**
                When leaving a job, you have options:
                - **Rollover to new 401(k)**: Simplest if new plan is good
                - **Rollover to IRA**: More investment options and control
                - **Leave it alone**: Only if the plan is excellent
                - **Never cash out**: Avoid taxes and penalties
                """,
                keyTakeaways: [
                    "Always contribute enough to get full employer match",
                    "Choose low-cost index funds or target-date funds",
                    "Increase contributions by 1% annually",
                    "Never cash out when changing jobs - roll it over instead"
                ],
                actionItems: [
                    "Check your current 401(k) contribution rate",
                    "Verify you're getting full employer match",
                    "Review your investment options and fees",
                    "Set up automatic annual contribution increases",
                    "Consider Roth vs Traditional based on your situation",
                    "Plan your rollover strategy for job changes"
                ],
                difficulty: .intermediate,
                readingTime: 9,
                tags: ["401k", "retirement", "employer match", "tax advantages"],
                relatedTopics: ["IRA vs Roth IRA", "Social Security Planning", "Retirement Withdrawal Strategies"]
            )
        ]
    }
    
    private func loadTipProgress() {
        if let data = UserDefaults.standard.data(forKey: "tipProgress"),
           let decoded = try? JSONDecoder().decode([UUID: TipProgress].self, from: data) {
            tipProgress = decoded
        }
    }
    
    private func loadBookmarkedTips() {
        if let data = UserDefaults.standard.data(forKey: "bookmarkedTips"),
           let decoded = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            bookmarkedTips = decoded
        }
    }
    
    func getTip(by id: UUID) -> FinancialTip? {
        return tips.first { $0.id == id }
    }
    
    func markTipAsRead(_ tipId: UUID) {
        if tipProgress[tipId] == nil {
            tipProgress[tipId] = TipProgress(tipId: tipId)
        }
        tipProgress[tipId]?.isRead = true
        tipProgress[tipId]?.readAt = Date()
        saveTipProgress()
    }
    
    func toggleBookmark(_ tipId: UUID) {
        if bookmarkedTips.contains(tipId) {
            bookmarkedTips.remove(tipId)
            tipProgress[tipId]?.isBookmarked = false
        } else {
            bookmarkedTips.insert(tipId)
            if tipProgress[tipId] == nil {
                tipProgress[tipId] = TipProgress(tipId: tipId)
            }
            tipProgress[tipId]?.isBookmarked = true
        }
        saveBookmarkedTips()
        saveTipProgress()
    }
    
    func completeActionItem(_ tipId: UUID, itemIndex: Int) {
        if tipProgress[tipId] == nil {
            tipProgress[tipId] = TipProgress(tipId: tipId)
        }
        
        if !tipProgress[tipId]!.completedActionItems.contains(itemIndex) {
            tipProgress[tipId]?.completedActionItems.append(itemIndex)
            saveTipProgress()
        }
    }
    
    func uncompleteActionItem(_ tipId: UUID, itemIndex: Int) {
        tipProgress[tipId]?.completedActionItems.removeAll { $0 == itemIndex }
        saveTipProgress()
    }
    
    private func saveTipProgress() {
        if let encoded = try? JSONEncoder().encode(tipProgress) {
            UserDefaults.standard.set(encoded, forKey: "tipProgress")
        }
    }
    
    private func saveBookmarkedTips() {
        if let encoded = try? JSONEncoder().encode(bookmarkedTips) {
            UserDefaults.standard.set(encoded, forKey: "bookmarkedTips")
        }
    }
    
    func getTipsByCategory(_ category: FinancialTip.TipCategory) -> [FinancialTip] {
        return tips.filter { $0.category == category }
    }
    
    func getTipsByDifficulty(_ difficulty: FinancialTip.Difficulty) -> [FinancialTip] {
        return tips.filter { $0.difficulty == difficulty }
    }
    
    func getBookmarkedTips() -> [FinancialTip] {
        return tips.filter { bookmarkedTips.contains($0.id) }
    }
    
    func getProgress(for tipId: UUID) -> TipProgress? {
        return tipProgress[tipId]
    }
    
    func searchTips(_ searchText: String) -> [FinancialTip] {
        guard !searchText.isEmpty else { return tips }
        
        return tips.filter { tip in
            tip.title.localizedCaseInsensitiveContains(searchText) ||
            tip.content.localizedCaseInsensitiveContains(searchText) ||
            tip.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}
