//
//  TrainingView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct TrainingView: View {
    let trainingType: TrainingType
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var viewModel: TrainingViewModel
    @State private var selectedAnswer: String?
    @State private var currentQuestion: TrainingQuestion?
    @State private var showingCompletionView = false
    
    init(trainingType: TrainingType) {
        self.trainingType = trainingType
        self._viewModel = State(initialValue: TrainingViewModel(trainingType: trainingType))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.green.opacity(0.05), .blue.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    TrainingLoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    TrainingErrorView(message: errorMessage) {
                        Task {
                            await viewModel.loadTrainingQuestions()
                        }
                    }
                } else if viewModel.hasCompleted {
                    TrainingCompletionView(sessionStats: viewModel.sessionStats) {
                        dismiss()
                    }
                } else if let question = viewModel.currentQuestion {
                    trainingContentView(question: question)
                } else {
                    TrainingNoQuestionsView {
                        dismiss()
                    }
                }
            }
            .navigationTitle(trainingType.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Exit") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    TrainingProgressView(
                        currentQuestionIndex: viewModel.currentQuestionIndex,
                        totalQuestions: viewModel.totalQuestions,
                        progress: viewModel.progress
                    )
                }
            }
        }
        .task {
            await viewModel.loadTrainingQuestions()
        }
    }
    
    // MARK: - Training Content
    
    private func trainingContentView(question: TrainingQuestion) -> some View {
        VStack(spacing: 0) {
            // Scrollable content area (Question + Options)
            ScrollView {
                VStack(spacing: 24) {
                    // Question area
                    TrainingQuestionAreaView(question: question)
                    
                    // Options
                    TrainingOptionsView(
                        question: question,
                        selectedAnswer: selectedAnswer
                    ) { userAnswer, correctAnswer in
                        submitAnswer(userAnswer, correctAnswer: correctAnswer)
                    }
                }
                .padding()
            }
            
            // Fixed bottom area for result feedback
            if viewModel.showingResult, let result = viewModel.lastResult {
                VStack(spacing: 16) {
                    Divider()
                    
                    HStack {
                        Text(result.isCorrect ? "🎉" : "😔")
                            .font(.title)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.isCorrect ? "Correct!" : "Wrong")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(result.isCorrect ? .green : .red)
                            
                            if !result.isCorrect {
                                Text("Correct answer: \(result.correctAnswer)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Button("Next Question") {
                        nextQuestion()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(.ultraThinMaterial)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func submitAnswer(_ userAnswer: String, correctAnswer: String) {
        selectedAnswer = userAnswer
        
        let isCorrect = userAnswer == correctAnswer
        
        viewModel.submitAnswer(userAnswer: userAnswer, isCorrect: isCorrect)
    }
    
    private func nextQuestion() {
        selectedAnswer = nil
        withAnimation {
            viewModel.moveToNextQuestion()
        }
    }
}

#Preview {
    TrainingView(trainingType: .imageToName)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}