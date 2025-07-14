//
//  TrainingQuestionAreaView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingQuestionAreaView: View {
    let question: TrainingQuestion
    
    var body: some View {
        VStack(spacing: 16) {
            // Show image, user selects name
            ZStack {
                // Background blur effect
                AsyncImage(url: URL(string: question.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .blur(radius: 20)
                        .clipped()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 250)
                        .blur(radius: 20)
                        .clipped()
                }
                
                // Main image
                AsyncImage(url: URL(string: question.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 250)
                        .clipped()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 8)
            
            Text("What breed is this?")
                .font(.title2)
                .fontWeight(.semibold)
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
    
    TrainingQuestionAreaView(question: sampleQuestion)
        .padding()
}