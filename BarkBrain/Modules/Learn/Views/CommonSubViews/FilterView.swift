//
//  FilterView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct FilterView: View {
    @Binding var searchText: String
    @Binding var selectedCategory: String
    @Binding var sortOption: SortOption
    
    let categories: [String]
    let filteredCount: Int
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case category = "Category"
        case learned = "Learned"
        
        var icon: String {
            switch self {
            case .name: return "textformat.abc"
            case .category: return "tag"
            case .learned: return "checkmark.circle"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Category Filter
            HStack(spacing: 8) {
                Image(systemName: "tag.fill")
                    .foregroundStyle(.blue)
                    .font(.caption)
                
                Text("\(filteredCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 32)
            }
            
            // Sort Options - Segment
            HStack(spacing: 8) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(.orange)
                    .font(.caption)
                
                Picker("Sort Method", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    @State var searchText = ""
    @State var selectedCategory = "All"
    @State var sortOption = FilterView.SortOption.name
    
    return FilterView(
        searchText: $searchText,
        selectedCategory: $selectedCategory,
        sortOption: $sortOption,
        categories: ["All", "Sporting", "Working", "Herding", "Hound"],
        filteredCount: 162
    )
    .padding()
}