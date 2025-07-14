//
//  CategoryChip.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? .blue : .gray.opacity(0.2),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryChip(title: "All", isSelected: true) { }
        CategoryChip(title: "Sporting", isSelected: false) { }
        CategoryChip(title: "Working", isSelected: false) { }
    }
    .padding()
}