//
//  TrainingCompletionView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingCompletionView: View {
    let sessionStats: TrainingSessionStats
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🏆")
                .font(.system(size: 80))
            
            Text("Training Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                Text("Session Statistics")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("\(sessionStats.correctCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        Text("Correct")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text("\(sessionStats.totalQuestions)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    VStack {
                        Text("\(Int(sessionStats.accuracy * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.orange)
                        Text("Accuracy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            
            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

