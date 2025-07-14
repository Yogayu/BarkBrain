//
//  ProgressCard.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct ProgressCard: View {
    let title: String
    let value: Int
    let total: Int?
    let color: Color
    let icon: String
    let showAsPercentage: Bool
    let unit: String
    
    init(title: String, value: Int, total: Int?, color: Color, icon: String, showAsPercentage: Bool = false, unit: String = "") {
        self.title = title
        self.value = value
        self.total = total
        self.color = color
        self.icon = icon
        self.showAsPercentage = showAsPercentage
        self.unit = unit
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(spacing: 1) {
                if let total = total {
                    if showAsPercentage {
                        Text("\(value)%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                    } else {
                        Text("\(value)/\(total)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(color)
                    }
                } else {
                    Text("\(value)\(unit)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Progress bar for items with totals
            if let total = total, !showAsPercentage {
                ProgressView(value: Double(value), total: Double(total))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.3)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 75, maxHeight: 75)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
}