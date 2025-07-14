//
//  TrainingOptionsView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingOptionsView: View {
    let question: TrainingQuestion
    let selectedAnswer: String?
    let onSubmitAnswer: (String, String) -> Void
    
    var body: some View {
        // Text options - single column layout
        VStack(spacing: 12) {
            ForEach(question.options, id: \.id) { breed in
                Button {
                    onSubmitAnswer(breed.displayName, question.correctBreed.displayName)
                } label: {
                    Text(breed.displayName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(backgroundColorForOption(breed.displayName, correct: question.correctBreed.displayName))
                                .stroke(borderColorForOption(breed.displayName, correct: question.correctBreed.displayName), lineWidth: 2)
                        )
                }
                .disabled(selectedAnswer != nil)
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func backgroundColorForOption(_ option: String, correct: String) -> Color {
        guard let selectedAnswer = selectedAnswer else {
            return .white.opacity(0.8)
        }
        
        if option == correct {
            return .green.opacity(0.3)
        } else if option == selectedAnswer && option != correct {
            return .red.opacity(0.3)
        } else {
            return .white.opacity(0.5)
        }
    }
    
    private func borderColorForOption(_ option: String, correct: String) -> Color {
        guard let selectedAnswer = selectedAnswer else {
            return .gray.opacity(0.3)
        }
        
        if option == correct {
            return .green
        } else if option == selectedAnswer && option != correct {
            return .red
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    let sampleBreed = Breed(name: "golden retriever")
    let sampleQuestion = TrainingQuestion(
        correctBreed: sampleBreed,
        options: [sampleBreed],
        imageURL: "https://example.com/image.jpg"
    )
    
    TrainingOptionsView(
        question: sampleQuestion,
        selectedAnswer: nil
    ) { answer, correct in
        print("Selected: \(answer), Correct: \(correct)")
    }
    .padding()
}