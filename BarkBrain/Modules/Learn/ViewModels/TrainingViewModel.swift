//
//  TrainingViewModel.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation
import CoreData
import AVFoundation
import UIKit

struct TrainingQuestion {
    let id = UUID()
    let correctBreed: Breed
    let options: [Breed]
    let imageURL: String
}

struct TrainingResult {
    let isCorrect: Bool
    let userAnswer: String
    let correctAnswer: String
    let timestamp: Date
}

struct TrainingSessionStats {
    var totalQuestions = 0
    var correctCount = 0
    var startTime: Date?
    var endTime: Date?
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
    
    var duration: TimeInterval {
        guard let startTime = startTime else { return 0 }
        let endTime = self.endTime ?? Date()
        return endTime.timeIntervalSince(startTime)
    }
}

@Observable
class TrainingViewModel {
    
    // MARK: - Dependencies
    
    private let trainingType: TrainingType
    private let apiService = DogAPIService()
    private let dataManager = DataManager.shared
    
    // MARK: - State
    
    private(set) var questions: [TrainingQuestion] = []
    private(set) var currentQuestionIndex = 0
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var sessionStats = TrainingSessionStats()
    private(set) var showingResult = false
    private(set) var lastResult: TrainingResult?
    
    // MARK: - Configuration
    
    private let numberOfOptions = 4
    private let maxQuestionsPerSession = 5
    
    // MARK: - Initialization
    
    init(trainingType: TrainingType) {
        self.trainingType = trainingType
    }
    
    // MARK: - Public Interface
    
    var currentQuestion: TrainingQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var totalQuestions: Int {
        questions.count
    }
    
    var hasCompleted: Bool {
        currentQuestionIndex >= questions.count && !questions.isEmpty
    }
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    // MARK: - Methods
    
    func loadTrainingQuestions() async {
        isLoading = true
        errorMessage = nil
        
        let untrainedBreeds = dataManager.getUntrainedBreeds()
        guard !untrainedBreeds.isEmpty else {
            isLoading = false
            return
        }
        
        // Limit the number of questions per session
        let selectedBreeds = Array(untrainedBreeds.shuffled().prefix(maxQuestionsPerSession))
        var generatedQuestions: [TrainingQuestion] = []
        
        for breed in selectedBreeds {
            do {
                let question = try await generateQuestion(for: breed)
                generatedQuestions.append(question)
            } catch {
                print("Failed to generate question for \(breed.name): \(error)")
                continue
            }
        }
        
        questions = generatedQuestions
        sessionStats.totalQuestions = questions.count
        sessionStats.startTime = Date()
        
        isLoading = false
    }
    
    func submitAnswer(userAnswer: String, isCorrect: Bool) {
        guard let question = currentQuestion else { return }
        
        let result = TrainingResult(
            isCorrect: isCorrect,
            userAnswer: userAnswer,
            correctAnswer: question.correctBreed.displayName,
            timestamp: Date()
        )
        
        lastResult = result
        showingResult = true
        
        // Update session stats
        if isCorrect {
            sessionStats.correctCount += 1
        }
        
        // Provide feedback (haptic and audio)
        provideFeedback(isCorrect: isCorrect)
        
        // Record the training result in Core Data
        recordTrainingResult(question: question, result: result)
    }
    
    func moveToNextQuestion() {
        showingResult = false
        lastResult = nil
        
        currentQuestionIndex += 1
        
        if hasCompleted {
            sessionStats.endTime = Date()
        }
    }
    
    // MARK: - Private Methods
    
    private func generateQuestion(for breedEntity: BreedEntity) async throws -> TrainingQuestion {
        let correctBreed = Breed(name: breedEntity.name)
        
        // Use a background context for CoreData operations to ensure thread safety
        let backgroundContext = PersistenceController.shared.container.newBackgroundContext()
        
        let allBreeds: [Breed] = try await withCheckedThrowingContinuation { continuation in
            backgroundContext.perform {
                do {
                    // Get all breeds for generating wrong options
                    let request: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
                    let allBreedEntities = try backgroundContext.fetch(request)
                    let breeds = allBreedEntities.map { Breed(name: $0.name) }
                    continuation.resume(returning: breeds)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        // Generate wrong options
        let wrongBreeds = allBreeds.filter { $0.name != correctBreed.name }
        let wrongOptions = Array(wrongBreeds.shuffled().prefix(numberOfOptions - 1))
        
        // Combine and shuffle all options
        var allOptions = wrongOptions + [correctBreed]
        allOptions.shuffle()
        
        // For image-to-name, we need one image for the question
        let imageURL = try await fetchFreshRandomImage(for: correctBreed)
        
        return TrainingQuestion(
            correctBreed: correctBreed,
            options: allOptions,
            imageURL: imageURL
        )
    }
    
    private func fetchFreshRandomImage(for breed: Breed) async throws -> String {
        // Try multiple times to get different images
        var attempts = 0
        let maxAttempts = 3
        var lastImageURL: String?
        
        while attempts < maxAttempts {
            let imageURL = try await apiService.fetchRandomImage(for: breed)
            
            // If this is the first attempt or we got a different URL, use it
            if lastImageURL == nil || lastImageURL != imageURL {
                return imageURL
            }
            
            lastImageURL = imageURL
            attempts += 1
            
            // Add a small delay before retry
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // If all attempts return the same URL, return it anyway
        return lastImageURL ?? ""
    }
    
    private func recordTrainingResult(question: TrainingQuestion, result: TrainingResult) {
        // Avoid CoreData object lifecycle issues by using breed name directly
        let breedName = question.correctBreed.name
        
        // Perform database operations asynchronously on main thread
        Task { @MainActor in
            // Use DataManager to find breed by name and record result
            // This avoids passing CoreData objects between contexts
            self.dataManager.recordTrainingResultByBreedName(
                breedName: breedName,
                trainingType: self.trainingType,
                userAnswer: result.userAnswer,
                correctAnswer: result.correctAnswer,
                isCorrect: result.isCorrect
            )
        }
    }
    
    // MARK: - Feedback Methods
    
    private func provideFeedback(isCorrect: Bool) {
        // Haptic feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(isCorrect ? .success : .error)
        
        // Audio feedback
        playAnswerSound(isCorrect: isCorrect)
    }
    
    private func playAnswerSound(isCorrect: Bool) {
        let soundID: SystemSoundID = isCorrect ? 1057 : 1053 // 正确音效和错误音效
        AudioServicesPlaySystemSound(soundID)
    }
}
