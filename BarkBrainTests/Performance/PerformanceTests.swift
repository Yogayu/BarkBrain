//
//  PerformanceTests.swift
//  BarkBrainTests
//
//  Created by YouXinyu on 2025/7/14.
//

import Testing
@testable import BarkBrain
import Foundation

/// Core performance tests
struct PerformanceTests {
    
    // MARK: - API Performance Tests
    
    @Test("API concurrent request performance")
    func apiConcurrentPerformance() async throws {
        let mockService = MockDogAPIService()
        mockService.shouldFail = false
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Simulate 5 concurrent requests
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 {
                group.addTask {
                    do {
                        _ = try await mockService.fetchAllBreeds()
                    } catch {
                        // Ignore errors in performance tests
                    }
                }
            }
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        #expect(timeElapsed < 1.0, "Concurrent requests took too long: \(timeElapsed)s")
    }
    
    // MARK: - Cache Performance Tests
    
    @Test("Image cache operation performance")
    func imageCachePerformance() async throws {
        let cacheManager = ImageCacheManager.shared
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Perform 50 cache lookup operations
        for i in 0..<50 {
            let testURL = "https://example.com/test\(i).jpg"
            _ = await cacheManager.getCachedImage(from: testURL)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        #expect(timeElapsed < 0.5, "Cache operations took too long: \(timeElapsed)s")
    }
    
    // MARK: - Model Performance Tests
    
    @Test("Breed model creation performance")
    func breedCreationPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Create 500 Breed instances
        var breeds: [Breed] = []
        for i in 0..<500 {
            breeds.append(Breed(name: "breed\(i)"))
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        #expect(timeElapsed < 0.1, "Model creation took too long: \(timeElapsed)s")
        #expect(breeds.count == 500)
    }
    
    @Test("GameState performance test")
    func gameStatePerformance() async throws {
        let gameState = GameState()
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Record 1000 answers
        for i in 0..<1000 {
            gameState.recordAnswer(isCorrect: i % 2 == 0)
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        #expect(gameState.totalQuestions == 1000)
        #expect(timeElapsed < 0.1, "GameState operations took too long: \(timeElapsed)s")
    }
}
