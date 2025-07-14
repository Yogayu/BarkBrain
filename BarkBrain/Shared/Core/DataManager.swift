//
//  DataManager.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation
import CoreData

@Observable
class DataManager {
    static let shared = DataManager()
    
    private let persistenceController = PersistenceController.shared
    private let apiService = DogAPIService()
    
    private init() {}
    
    // MARK: - Breed Management
    
    func initializeBreedsData() async {
        let context = persistenceController.container.viewContext
        
        // Check if breeds are already initialized
        let request: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
        let existingCount = (try? context.count(for: request)) ?? 0
        
        if existingCount > 0 {
            return // Already initialized
        }
        
        do {
            let apiBreeds = try await apiService.fetchAllBreeds()
            let breedInfoData = loadBreedInfoFromJSON()
            
            for apiBreed in apiBreeds {
                let breedEntity = BreedEntity(context: context)
                breedEntity.id = UUID().uuidString
                breedEntity.name = apiBreed.name
                breedEntity.displayName = apiBreed.displayName
                breedEntity.isLearned = false
                
                // Add category and detailed info from local data
                if let breedInfo = breedInfoData[apiBreed.name] {
                    breedEntity.category = breedInfo.category
                    breedEntity.origin = breedInfo.origin
                    breedEntity.characteristics = breedInfo.characteristics
                } else {
                    breedEntity.category = categorizeBreed(apiBreed.name)
                    breedEntity.origin = "Unknown"
                    breedEntity.characteristics = "A wonderful dog breed with unique characteristics that vary greatly across different breeds. Some dogs are naturally energetic and playful, while others are calm and gentle companions. Each breed possesses distinct personality traits that make them suitable for different lifestyles and families."
                }
            }
            
            persistenceController.save()
            
            // Initialize user progress
            initializeUserProgress(totalBreeds: apiBreeds.count)
            
            
        } catch {
            print("Failed to initialize breeds data: \(error)")
        }
    }
    
    private func loadBreedInfoFromJSON() -> [String: BreedDetailInfo] {
        guard let url = Bundle.main.url(forResource: "BreedInfo", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let breedInfoArray = try? JSONDecoder().decode([BreedDetailInfo].self, from: data) else {
            return [:]
        }
        
        var breedInfoDict: [String: BreedDetailInfo] = [:]
        for info in breedInfoArray {
            breedInfoDict[info.name] = info
        }
        return breedInfoDict
    }
    
    private func categorizeBreed(_ breedName: String) -> String {
        let name = breedName.lowercased()
        
        if name.contains("retriever") || name.contains("spaniel") || name.contains("pointer") {
            return "Sporting"
        } else if name.contains("terrier") {
            return "Terrier"
        } else if name.contains("hound") {
            return "Hound"
        } else if name.contains("shepherd") || name.contains("collie") || name.contains("cattle") {
            return "Herding"
        } else if name.contains("poodle") || name.contains("bichon") || name.contains("maltese") {
            return "Non-Sporting"
        } else if name.contains("chihuahua") || name.contains("pug") || name.contains("york") {
            return "Toy"
        } else if name.contains("mastiff") || name.contains("rottweiler") || name.contains("boxer") {
            return "Working"
        } else {
            return "Mixed"
        }
    }
    
    private func initializeUserProgress(totalBreeds: Int) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        
        if ((try? context.fetch(request).first) != nil) {
            return // Already exists
        }
        
        let userProgress = UserProgress(context: context)
        userProgress.totalBreedsCount = Int32(totalBreeds)
        userProgress.learnedBreedsCount = 0
        userProgress.trainedBreedsCount = 0
        userProgress.totalQuestions = 0
        userProgress.correctAnswers = 0
        userProgress.currentStreak = 0
        userProgress.bestStreak = 0
        userProgress.consecutiveStudyDays = 0
        
        persistenceController.save()
    }
    
    
    // MARK: - Training Management
    
    func getUntrainedBreeds() -> [BreedEntity] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
        
        // Get breeds that haven't been trained yet using traditional CoreData approach
        let trainingRequest: NSFetchRequest<TrainingRecord> = TrainingRecord.fetchRequest()
        
        do {
            // Fetch all training records and extract unique breed IDs
            let trainingRecords = try context.fetch(trainingRequest)
            let trainedBreedIDs = Array(Set(trainingRecords.map { $0.breedID }))
            
            if !trainedBreedIDs.isEmpty {
                request.predicate = NSPredicate(format: "NOT (id IN %@)", trainedBreedIDs)
            }
        } catch {
            print("Failed to fetch trained breed IDs: \(error)")
            // Continue without filtering if fetch fails
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BreedEntity.displayName, ascending: true)]
        
        return (try? context.fetch(request)) ?? []
    }
    
    func recordTrainingResultByBreedName(
        breedName: String,
        trainingType: TrainingType,
        userAnswer: String,
        correctAnswer: String,
        isCorrect: Bool
    ) {
        let context = persistenceController.container.viewContext
        
        // Find breed entity by name and directly get the ID
        let breedRequest: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
        breedRequest.predicate = NSPredicate(format: "name == %@", breedName)
        breedRequest.propertiesToFetch = ["id"] // Only fetch the ID property
        
        do {
            guard let breedEntity = try context.fetch(breedRequest).first else {
                print("Warning: Could not find breed entity for name: \(breedName)")
                return
            }
            
            // Try to access the ID property, force fault if needed
            let breedID: String
            if breedEntity.isFault {
                // Force the fault to fire by accessing a property
                _ = breedEntity.name
                breedID = breedEntity.id
            } else {
                breedID = breedEntity.id
            }
            
            // Use existing method with breedID
            recordTrainingResult(
                breedID: breedID,
                trainingType: trainingType,
                userAnswer: userAnswer,
                correctAnswer: correctAnswer,
                isCorrect: isCorrect
            )
        } catch {
            print("Error finding breed entity for name \(breedName): \(error)")
        }
    }
    
    func recordTrainingResult(
        breedID: String,
        trainingType: TrainingType,
        userAnswer: String,
        correctAnswer: String,
        isCorrect: Bool
    ) {
        let context = persistenceController.container.viewContext
        
        // Check if this is the first time training this breed
        let existingRecordRequest: NSFetchRequest<TrainingRecord> = TrainingRecord.fetchRequest()
        existingRecordRequest.predicate = NSPredicate(format: "breedID == %@", breedID)
        let isFirstTraining = ((try? context.count(for: existingRecordRequest)) ?? 0) == 0
        
        // Create training record
        let record = TrainingRecord(context: context)
        record.id = UUID().uuidString
        record.breedID = breedID
        record.trainingType = trainingType.rawValue
        record.userAnswer = userAnswer
        record.correctAnswer = correctAnswer
        record.isCorrect = isCorrect
        record.timestamp = Date()
        
        // Update user progress - only increase trained count if correct and first time
        updateUserProgress(isCorrect: isCorrect, isFirstTrainingAndCorrect: isFirstTraining && isCorrect)
        
        persistenceController.save()
    }
    
    private func updateUserProgress(isCorrect: Bool, isFirstTrainingAndCorrect: Bool = false) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
        
        guard let progress = try? context.fetch(request).first else { return }
        
        progress.totalQuestions += 1
        
        // Update trained breeds count only if this is the first time training this breed AND user got it correct
        if isFirstTrainingAndCorrect {
            progress.trainedBreedsCount += 1
        }
        
        if isCorrect {
            progress.correctAnswers += 1
            progress.currentStreak += 1
            progress.bestStreak = max(progress.bestStreak, progress.currentStreak)
        } else {
            progress.currentStreak = 0
        }
        
        // Update study date
        let today = Calendar.current.startOfDay(for: Date())
        if let lastStudyDate = progress.lastStudyDate {
            let lastStudyDay = Calendar.current.startOfDay(for: lastStudyDate)
            let daysDiff = Calendar.current.dateComponents([.day], from: lastStudyDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                progress.consecutiveStudyDays += 1
            } else if daysDiff > 1 {
                progress.consecutiveStudyDays = 1
            }
        } else {
            progress.consecutiveStudyDays = 1
        }
        
        progress.lastStudyDate = Date()
    }
    
    
    
    // MARK: - Helper Methods
    
    func markBreedAsLearned(_ breedID: String) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", breedID)
        
        guard let breed = try? context.fetch(request).first else { return }
        
        if !breed.isLearned {
            breed.isLearned = true
            breed.dateFirstViewed = Date()
            
            // Update progress count
            let progressRequest: NSFetchRequest<UserProgress> = UserProgress.fetchRequest()
            if let progress = try? context.fetch(progressRequest).first {
                progress.learnedBreedsCount += 1
            }
            
            persistenceController.save()
        }
    }
    
    func updateBreedNotes(_ breedID: String, notes: String) {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<BreedEntity> = BreedEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", breedID)
        
        guard let breed = try? context.fetch(request).first else { return }
        
        breed.userNotes = notes
        persistenceController.save()
    }
}

// MARK: - Supporting Types

enum TrainingType: String, CaseIterable {
    case imageToName = "imageToName"
    
    var displayName: String {
        return "Image To Name"
    }
}

struct BreedDetailInfo: Codable {
    let name: String
    let category: String
    let origin: String
    let characteristics: String
    let temperament: String?
    let size: String?
    let lifespan: String?
}

