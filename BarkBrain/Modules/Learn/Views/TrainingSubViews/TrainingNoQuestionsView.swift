//
//  TrainingNoQuestionsView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingNoQuestionsView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Awesome!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You have trained all available dog breeds!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Back") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    TrainingNoQuestionsView {
        print("Dismiss tapped")
    }
}