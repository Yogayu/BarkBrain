//
//  EmptyStateView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct EmptyStateView: View {
    let selectedCategory: Binding<String>
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40, weight: .light))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 12) {
                Text("No Breeds Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Try adjusting your search terms or\nselecting a different category")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            
            // Suggestion chips
            VStack(spacing: 8) {
                Text("Popular categories:")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                
                HStack(spacing: 8) {
                    ForEach(["Sporting", "Working", "Herding"], id: \.self) { category in
                        Button {
                            withAnimation(.spring()) {
                                selectedCategory.wrappedValue = category
                            }
                        } label: {
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.blue.opacity(0.1), in: Capsule())
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    @State var selectedCategory = "All"
    
    return EmptyStateView(selectedCategory: $selectedCategory)
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color.mint.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}