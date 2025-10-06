//
//  ContentView.swift
//  QuizFi Total
//
//  Created by Вячеслав on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QuizzesView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quizzes")
                }
                .tag(0)
            
            PuzzlesView()
                .tabItem {
                    Image(systemName: "puzzlepiece.fill")
                    Text("Puzzles")
                }
                .tag(1)
            
            FinanceTipsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Tips")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.appAccent)
        .background(Color.appBackground)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
