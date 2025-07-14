//
//  ContentView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var hasInitializedData = false
    
    var body: some View {
        LearnView()
        .task {
            if !hasInitializedData {
                await DataManager.shared.initializeBreedsData()
                hasInitializedData = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
