//
//  TrainingProgressView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingProgressView: View {
    let currentQuestionIndex: Int
    let totalQuestions: Int
    let progress: Double
    
    var body: some View {
        HStack(spacing: 8) {
            Text("\(currentQuestionIndex + 1)/\(totalQuestions)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            ProgressView(value: progress)
                .frame(width: 60)
        }
    }
}

#Preview {
    TrainingProgressView(
        currentQuestionIndex: 2,
        totalQuestions: 10,
        progress: 0.3
    )
}