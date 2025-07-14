//
//  PersistenceController.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import CoreData
import Foundation

class PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add sample data for previews
        let sampleBreed = BreedEntity(context: viewContext)
        sampleBreed.id = UUID().uuidString
        sampleBreed.name = "golden retriever"
        sampleBreed.displayName = "Golden Retriever"
        sampleBreed.category = "Sporting"
        sampleBreed.isLearned = true
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Create the Core Data model programmatically since we can't create .xcdatamodeld files
        let model = NSManagedObjectModel()
        
        // BreedEntity
        let breedEntity = NSEntityDescription()
        breedEntity.name = "BreedEntity"
        breedEntity.managedObjectClassName = "BreedEntity"
        
        let breedIdAttribute = NSAttributeDescription()
        breedIdAttribute.name = "id"
        breedIdAttribute.attributeType = .stringAttributeType
        breedIdAttribute.isOptional = false
        
        let breedNameAttribute = NSAttributeDescription()
        breedNameAttribute.name = "name"
        breedNameAttribute.attributeType = .stringAttributeType
        breedNameAttribute.isOptional = false
        
        let breedDisplayNameAttribute = NSAttributeDescription()
        breedDisplayNameAttribute.name = "displayName"
        breedDisplayNameAttribute.attributeType = .stringAttributeType
        breedDisplayNameAttribute.isOptional = false
        
        let breedCategoryAttribute = NSAttributeDescription()
        breedCategoryAttribute.name = "category"
        breedCategoryAttribute.attributeType = .stringAttributeType
        breedCategoryAttribute.isOptional = false
        
        let breedOriginAttribute = NSAttributeDescription()
        breedOriginAttribute.name = "origin"
        breedOriginAttribute.attributeType = .stringAttributeType
        breedOriginAttribute.isOptional = true
        
        let breedCharacteristicsAttribute = NSAttributeDescription()
        breedCharacteristicsAttribute.name = "characteristics"
        breedCharacteristicsAttribute.attributeType = .stringAttributeType
        breedCharacteristicsAttribute.isOptional = true
        
        let breedUserNotesAttribute = NSAttributeDescription()
        breedUserNotesAttribute.name = "userNotes"
        breedUserNotesAttribute.attributeType = .stringAttributeType
        breedUserNotesAttribute.isOptional = true
        
        let breedDateFirstViewedAttribute = NSAttributeDescription()
        breedDateFirstViewedAttribute.name = "dateFirstViewed"
        breedDateFirstViewedAttribute.attributeType = .dateAttributeType
        breedDateFirstViewedAttribute.isOptional = true
        
        let breedIsLearnedAttribute = NSAttributeDescription()
        breedIsLearnedAttribute.name = "isLearned"
        breedIsLearnedAttribute.attributeType = .booleanAttributeType
        breedIsLearnedAttribute.defaultValue = false
        
        breedEntity.properties = [
            breedIdAttribute,
            breedNameAttribute,
            breedDisplayNameAttribute,
            breedCategoryAttribute,
            breedOriginAttribute,
            breedCharacteristicsAttribute,
            breedUserNotesAttribute,
            breedDateFirstViewedAttribute,
            breedIsLearnedAttribute
        ]
        
        // TrainingRecord
        let trainingRecordEntity = NSEntityDescription()
        trainingRecordEntity.name = "TrainingRecord"
        trainingRecordEntity.managedObjectClassName = "TrainingRecord"
        
        let trainingIdAttribute = NSAttributeDescription()
        trainingIdAttribute.name = "id"
        trainingIdAttribute.attributeType = .stringAttributeType
        trainingIdAttribute.isOptional = false
        
        let trainingBreedIDAttribute = NSAttributeDescription()
        trainingBreedIDAttribute.name = "breedID"
        trainingBreedIDAttribute.attributeType = .stringAttributeType
        trainingBreedIDAttribute.isOptional = false
        
        let trainingTypeAttribute = NSAttributeDescription()
        trainingTypeAttribute.name = "trainingType"
        trainingTypeAttribute.attributeType = .stringAttributeType
        trainingTypeAttribute.isOptional = false
        
        let trainingQuestionTextAttribute = NSAttributeDescription()
        trainingQuestionTextAttribute.name = "questionText"
        trainingQuestionTextAttribute.attributeType = .stringAttributeType
        trainingQuestionTextAttribute.isOptional = true
        
        let trainingCorrectAnswerAttribute = NSAttributeDescription()
        trainingCorrectAnswerAttribute.name = "correctAnswer"
        trainingCorrectAnswerAttribute.attributeType = .stringAttributeType
        trainingCorrectAnswerAttribute.isOptional = false
        
        let trainingUserAnswerAttribute = NSAttributeDescription()
        trainingUserAnswerAttribute.name = "userAnswer"
        trainingUserAnswerAttribute.attributeType = .stringAttributeType
        trainingUserAnswerAttribute.isOptional = false
        
        let trainingIsCorrectAttribute = NSAttributeDescription()
        trainingIsCorrectAttribute.name = "isCorrect"
        trainingIsCorrectAttribute.attributeType = .booleanAttributeType
        trainingIsCorrectAttribute.defaultValue = false
        
        let trainingTimestampAttribute = NSAttributeDescription()
        trainingTimestampAttribute.name = "timestamp"
        trainingTimestampAttribute.attributeType = .dateAttributeType
        trainingTimestampAttribute.isOptional = false
        
        trainingRecordEntity.properties = [
            trainingIdAttribute,
            trainingBreedIDAttribute,
            trainingTypeAttribute,
            trainingQuestionTextAttribute,
            trainingCorrectAnswerAttribute,
            trainingUserAnswerAttribute,
            trainingIsCorrectAttribute,
            trainingTimestampAttribute
        ]
        
        
        
        // UserProgress
        let userProgressEntity = NSEntityDescription()
        userProgressEntity.name = "UserProgress"
        userProgressEntity.managedObjectClassName = "UserProgress"
        
        let progressTotalBreedsAttribute = NSAttributeDescription()
        progressTotalBreedsAttribute.name = "totalBreedsCount"
        progressTotalBreedsAttribute.attributeType = .integer32AttributeType
        progressTotalBreedsAttribute.defaultValue = 0
        
        let progressLearnedBreedsAttribute = NSAttributeDescription()
        progressLearnedBreedsAttribute.name = "learnedBreedsCount"
        progressLearnedBreedsAttribute.attributeType = .integer32AttributeType
        progressLearnedBreedsAttribute.defaultValue = 0
        
        let progressTrainedBreedsAttribute = NSAttributeDescription()
        progressTrainedBreedsAttribute.name = "trainedBreedsCount"
        progressTrainedBreedsAttribute.attributeType = .integer32AttributeType
        progressTrainedBreedsAttribute.defaultValue = 0
        
        let progressTotalQuestionsAttribute = NSAttributeDescription()
        progressTotalQuestionsAttribute.name = "totalQuestions"
        progressTotalQuestionsAttribute.attributeType = .integer32AttributeType
        progressTotalQuestionsAttribute.defaultValue = 0
        
        let progressCorrectAnswersAttribute = NSAttributeDescription()
        progressCorrectAnswersAttribute.name = "correctAnswers"
        progressCorrectAnswersAttribute.attributeType = .integer32AttributeType
        progressCorrectAnswersAttribute.defaultValue = 0
        
        let progressCurrentStreakAttribute = NSAttributeDescription()
        progressCurrentStreakAttribute.name = "currentStreak"
        progressCurrentStreakAttribute.attributeType = .integer32AttributeType
        progressCurrentStreakAttribute.defaultValue = 0
        
        let progressBestStreakAttribute = NSAttributeDescription()
        progressBestStreakAttribute.name = "bestStreak"
        progressBestStreakAttribute.attributeType = .integer32AttributeType
        progressBestStreakAttribute.defaultValue = 0
        
        let progressLastStudyDateAttribute = NSAttributeDescription()
        progressLastStudyDateAttribute.name = "lastStudyDate"
        progressLastStudyDateAttribute.attributeType = .dateAttributeType
        progressLastStudyDateAttribute.isOptional = true
        
        let progressConsecutiveStudyDaysAttribute = NSAttributeDescription()
        progressConsecutiveStudyDaysAttribute.name = "consecutiveStudyDays"
        progressConsecutiveStudyDaysAttribute.attributeType = .integer32AttributeType
        progressConsecutiveStudyDaysAttribute.defaultValue = 0
        
        userProgressEntity.properties = [
            progressTotalBreedsAttribute,
            progressLearnedBreedsAttribute,
            progressTrainedBreedsAttribute,
            progressTotalQuestionsAttribute,
            progressCorrectAnswersAttribute,
            progressCurrentStreakAttribute,
            progressBestStreakAttribute,
            progressLastStudyDateAttribute,
            progressConsecutiveStudyDaysAttribute
        ]
        
        model.entities = [breedEntity, trainingRecordEntity, userProgressEntity]
        
        container = NSPersistentContainer(name: "BarkBrain", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
