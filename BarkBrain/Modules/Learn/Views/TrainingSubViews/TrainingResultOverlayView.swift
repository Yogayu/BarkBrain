//
//  TrainingResultOverlayView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingResultOverlayView: View {
    let result: TrainingResult
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(result.isCorrect ? "🎉" : "😔")
                    .font(.system(size: 80))
                
                Text(result.isCorrect ? "Correct!" : "Wrong")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(result.isCorrect ? .green : .red)
                
                if !result.isCorrect {
                    Text("Correct answer is: \(result.correctAnswer)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
