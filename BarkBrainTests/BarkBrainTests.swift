//
//  BarkBrainTests.swift
//  BarkBrainTests
//
//  Created by YouXinyu on 2025/7/13.
//

import Testing
@testable import BarkBrain
import Foundation

/// Core functionality tests
struct BarkBrainTests {
    
    // MARK: - Core Model Tests
    
    @Test("Breed basic functionality")
    func breedBasicTest() async throws {
        let breed = Breed(name: "labrador")
        #expect(breed.displayName == "Labrador")
        #expect(!breed.id.uuidString.isEmpty)
    }
    
    @Test("GameState core functionality")
    func gameStateBasicTest() async throws {
        let gameState = GameState()
        
        // Test initial state
        #expect(gameState.currentScore == 0)
        #expect(gameState.accuracy == 0.0)
        
        // Test answer recording
        gameState.recordAnswer(isCorrect: true)
        #expect(gameState.currentScore == 1)
        #expect(gameState.accuracy == 1.0)
        
        gameState.recordAnswer(isCorrect: false)
        #expect(gameState.currentScore == 1)
        #expect(gameState.accuracy == 0.5)
    }
    
    // MARK: - API Service Tests
    
    @Test("API service basic functionality")
    func apiServiceBasicTest() async throws {
        let mockService = MockDogAPIService()
        mockService.shouldFail = false
        
        let breeds = try await mockService.fetchAllBreeds()
        #expect(breeds.count > 0)
        
        let imageURL = try await mockService.fetchRandomImage()
        #expect(!imageURL.isEmpty)
    }
    
    @Test("API error handling")
    func apiErrorHandlingTest() async throws {
        let mockService = MockDogAPIService()
        mockService.shouldFail = true
        
        do {
            _ = try await mockService.fetchAllBreeds()
            #expect(Bool(false), "Should throw error")
        } catch is DogAPIError {
            // Expected behavior
        }
    }
    
    // MARK: - JSON Parsing Tests
    
    @Test("JSON parsing functionality")
    func jsonDecodingTest() async throws {
        let json = """
        {
            "message": {
                "labrador": ["golden"]
            },
            "status": "success"
        }
        """
        
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(DogBreedsResponse.self, from: data)
        
        #expect(response.status == "success")
        #expect(response.message.keys.contains("labrador"))
    }
}
