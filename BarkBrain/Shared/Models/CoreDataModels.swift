//
//  CoreDataModels.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation
import CoreData

// MARK: - BreedEntity

@objc(BreedEntity)
public class BreedEntity: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var displayName: String
    @NSManaged public var category: String
    @NSManaged public var origin: String?
    @NSManaged public var characteristics: String?
    @NSManaged public var userNotes: String?
    @NSManaged public var dateFirstViewed: Date?
    @NSManaged public var isLearned: Bool
    @NSManaged public var trainingRecords: NSSet?
}

extension BreedEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BreedEntity> {
        return NSFetchRequest<BreedEntity>(entityName: "BreedEntity")
    }
}

extension BreedEntity: Identifiable {
    // NSManagedObject already has an ObjectIdentifier, but we can use our custom id
    // The `id` property is already defined as @NSManaged public var id: String
}

// MARK: - TrainingRecord

@objc(TrainingRecord)
public class TrainingRecord: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var breedID: String
    @NSManaged public var trainingType: String // "imageToName"
    @NSManaged public var questionText: String?
    @NSManaged public var correctAnswer: String
    @NSManaged public var userAnswer: String
    @NSManaged public var isCorrect: Bool
    @NSManaged public var timestamp: Date
    @NSManaged public var breed: BreedEntity?
}

extension TrainingRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrainingRecord> {
        return NSFetchRequest<TrainingRecord>(entityName: "TrainingRecord")
    }
}


// MARK: - UserProgress

@objc(UserProgress)
public class UserProgress: NSManagedObject {
    @NSManaged public var totalBreedsCount: Int32
    @NSManaged public var learnedBreedsCount: Int32
    @NSManaged public var trainedBreedsCount: Int32
    @NSManaged public var totalQuestions: Int32
    @NSManaged public var correctAnswers: Int32
    @NSManaged public var currentStreak: Int32
    @NSManaged public var bestStreak: Int32
    @NSManaged public var lastStudyDate: Date?
    @NSManaged public var consecutiveStudyDays: Int32
}

extension UserProgress {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProgress> {
        return NSFetchRequest<UserProgress>(entityName: "UserProgress")
    }
}
