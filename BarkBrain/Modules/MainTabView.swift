//
//  MainTabView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

// TODO: For future review and achievements

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var hasInitializedData = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearnView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Learn")
                }
                .tag(0)
        }
        .accentColor(.blue)
        .task {
            if !hasInitializedData {
                await DataManager.shared.initializeBreedsData()
                hasInitializedData = true
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
