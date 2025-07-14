//
//  GameState.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/14.
//

import Foundation

@Observable
class GameState {
    var currentScore: Int = 0
    var totalQuestions: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    
    func recordAnswer(isCorrect: Bool) {
        totalQuestions += 1
        if isCorrect {
            currentScore += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
        } else {
            streak = 0
        }
    }
    
    func reset() {
        currentScore = 0
        totalQuestions = 0
        streak = 0
    }
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentScore) / Double(totalQuestions)
    }
}
