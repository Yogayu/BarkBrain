//
//  DogFactsService.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation

// MARK: - Dog Fact Model

/// Dog fact with emoji
struct DogFact {
    let fact: String
    
    let emoji: String
    
    static let allFacts = [
        DogFact(fact: "Dogs have an incredible sense of smell that's 10,000 to 100,000 times better than humans!", emoji: "👃"),
        DogFact(fact: "A dog's nose print is unique, just like a human's fingerprint.", emoji: "🐕"),
        DogFact(fact: "Dogs can learn over 150 words and can count up to four or five.", emoji: "🧠"),
        DogFact(fact: "Greyhounds can run up to 45 mph, making them the fastest dog breed.", emoji: "💨"),
        DogFact(fact: "Dalmatians are born completely white and develop their spots as they grow.", emoji: "⚫"),
        DogFact(fact: "A dog's mouth exerts 150-300 pounds of pressure per square inch.", emoji: "💪"),
        DogFact(fact: "Dogs only sweat through their paw pads and nose.", emoji: "🦶"),
        DogFact(fact: "Puppies are born deaf and blind, but their hearing is so sharp they can hear sounds at frequencies twice as high as humans.", emoji: "👂"),
        DogFact(fact: "Border Collies are considered the most intelligent dog breed.", emoji: "🎓"),
        DogFact(fact: "Dogs have three eyelids: upper, lower, and a third lid called the nictitating membrane.", emoji: "👁️"),
        DogFact(fact: "The Basenji is known as the 'barkless dog' but they can yodel!", emoji: "🎵"),
        DogFact(fact: "Small dogs generally live longer than large dogs.", emoji: "⏰"),
        DogFact(fact: "Dogs curl up in a ball when sleeping to conserve body heat and protect vital organs.", emoji: "😴"),
        DogFact(fact: "A dog's tail position can tell you a lot about their mood and intentions.", emoji: "📡"),
        DogFact(fact: "Dogs have been bred into over 400 distinct breeds worldwide.", emoji: "🌍")
    ]
    
    /// Returns a random dog fact
    static func random() -> DogFact {
        return allFacts.randomElement() ?? allFacts[0]
    }
}

// MARK: - Dog Facts Service

/// Dog facts service
class DogFactsService {
    static let shared = DogFactsService()
    
    private init() {}
    
    /// Determines whether to show a fact based on question count
    func shouldShowFact(questionCount: Int) -> Bool {
        // Show a fact every 2 questions, starting after the 1st question
        return questionCount > 1 && questionCount % 2 == 0
    }
    
    /// Gets a random dog fact
    func getRandomFact() -> DogFact {
        return DogFact.random()
    }
}
