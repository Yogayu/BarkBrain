//
//  DogAPIService.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation

// MARK: - Configuration

/// Configuration for DogAPIService
struct DogAPIConfiguration {
    let maxConcurrentRequests: Int
    let requestTimeout: TimeInterval
    let cacheExpirationTime: TimeInterval
    let enableCaching: Bool
    
    static let `default` = DogAPIConfiguration(
        maxConcurrentRequests: 5,
        requestTimeout: 10.0,
        cacheExpirationTime: 300, // 5 minutes
        enableCaching: true
    )
}

// MARK: - API Errors

enum DogAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case invalidResponse
    case timeout
    case cacheError
    case rateLimitExceeded
    case serverError(Int)
    case noDataReceived
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .timeout:
            return "Request timed out"
        case .cacheError:
            return "Cache operation failed"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .noDataReceived:
            return "No data received from server"
        }
    }
}

// MARK: - API Service Protocol

/// Dog breed API operations protocol
protocol DogAPIServiceProtocol {
    /// Fetches all available dog breeds
    func fetchAllBreeds() async throws -> [Breed]
    
    /// Fetches a fixed image URL for a specific breed
    func fetchFixedImage(for breed: Breed) async throws -> String
    
    /// Fetches multiple fixed image URLs for a specific breed
    func fetchFixedImages(for breed: Breed, count: Int) async throws -> [String]
    
    /// Fetches a random image URL for a specific breed
    func fetchRandomImage(for breed: Breed) async throws -> String
    
    /// Fetches a random image URL from any breed
    func fetchRandomImage() async throws -> String
}

// MARK: - Live API Service

/// Dog API service implementation
class DogAPIService: DogAPIServiceProtocol {
    private let baseURL = "https://dog.ceo/api"
    private let session: URLSession
    private let configuration: DogAPIConfiguration
    
    /// Cache for API responses to reduce network requests
    private let responseCache = NSCache<NSString, NSData>()
    
    init(session: URLSession = .shared, configuration: DogAPIConfiguration = .default) {
        self.session = session
        self.configuration = configuration
        
        // Configure cache limits
        responseCache.countLimit = 100
        responseCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    // MARK: - Private Helper Methods
    
    /// Generic method to perform API requests and decode responses
    private func performRequest<T: Codable>(
        url: URL,
        responseType: T.Type,
        useCache: Bool = true
    ) async throws -> T {
        let cacheKey = NSString(string: url.absoluteString)
        
        // Check cache first (only for cacheable requests and if caching is enabled)
        if useCache && configuration.enableCaching, let cachedData = responseCache.object(forKey: cacheKey) {
            do {
                let response = try JSONDecoder().decode(responseType, from: cachedData as Data)
                return response
            } catch {
                // If cached data is corrupted, remove it and continue with network request
                responseCache.removeObject(forKey: cacheKey)
            }
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            let response = try JSONDecoder().decode(responseType, from: data)
            
            // Cache the response data (only for cacheable requests and if caching is enabled)
            if useCache && configuration.enableCaching {
                responseCache.setObject(NSData(data: data), forKey: cacheKey)
            }
            
            return response
        } catch let error as DecodingError {
            throw DogAPIError.decodingError(error)
        } catch {
            throw DogAPIError.networkError(error)
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetches all available dog breeds
    func fetchAllBreeds() async throws -> [Breed] {
        guard let url = URL(string: "\(baseURL)/breeds/list/all") else {
            throw DogAPIError.invalidURL
        }
        
        let response = try await performRequest(url: url, responseType: DogBreedsResponse.self, useCache: true)
        
        guard response.status == "success" else {
            throw DogAPIError.invalidResponse
        }
        
        var breeds: [Breed] = []
        
        // Process main breeds and sub-breeds
        for (breedName, subBreeds) in response.message {
            if subBreeds.isEmpty {
                // Main breed without sub-breeds
                breeds.append(Breed(name: breedName))
            } else {
                // Create entries for each sub-breed
                for subBreed in subBreeds {
                    let fullBreedName = "\(subBreed) \(breedName)"
                    breeds.append(Breed(name: fullBreedName))
                }
            }
        }
        
        return breeds.sorted { $0.displayName < $1.displayName }
    }
    
    /// Fetches a fixed image URL for a specific breed
    func fetchFixedImage(for breed: Breed) async throws -> String {
        let breedPath = buildBreedPath(from: breed.name)
        guard let url = URL(string: "\(baseURL)/breed/\(breedPath)/images") else {
            throw DogAPIError.invalidURL
        }
        
        do {
            let response = try await performRequest(url: url, responseType: DogImagesResponse.self)
            
            guard response.status == "success", !response.message.isEmpty else {
                throw DogAPIError.noDataReceived
            }
            
            // Return the first available image
            return response.message[0]
        } catch {
            throw DogAPIError.invalidResponse
        }
    }
    
    /// Fetches multiple fixed image URLs for a specific breed
    func fetchFixedImages(for breed: Breed, count: Int = 6) async throws -> [String] {
        let breedPath = buildBreedPath(from: breed.name)
        guard let url = URL(string: "\(baseURL)/breed/\(breedPath)/images") else {
            throw DogAPIError.invalidURL
        }
        
        do {
            let response = try await performRequest(url: url, responseType: DogImagesResponse.self)
            
            guard response.status == "success", !response.message.isEmpty else {
                throw DogAPIError.noDataReceived
            }
            
            // Return up to 'count' images, or all available if fewer than requested
            let imagesToReturn = min(count, response.message.count)
            return Array(response.message.prefix(imagesToReturn))
        } catch {
            throw DogAPIError.invalidResponse
        }
    }
    
    /// Fetches a random image URL for a specific breed
    func fetchRandomImage(for breed: Breed) async throws -> String {
        let breedPath = buildBreedPath(from: breed.name)
        guard let url = URL(string: "\(baseURL)/breed/\(breedPath)/images/random") else {
            throw DogAPIError.invalidURL
        }
        
        let response = try await performRequest(url: url, responseType: DogImageResponse.self, useCache: false)
        
        guard response.status == "success" else {
            throw DogAPIError.invalidResponse
        }
        
        return response.message
    }
    
    /// Fetches a random image URL from any breed
    func fetchRandomImage() async throws -> String {
        guard let url = URL(string: "\(baseURL)/breeds/image/random") else {
            throw DogAPIError.invalidURL
        }
        
        let response = try await performRequest(url: url, responseType: DogImageResponse.self, useCache: false)
        
        guard response.status == "success" else {
            throw DogAPIError.invalidResponse
        }
        
        return response.message
    }
    
    /// Builds breed path for API requests
    private func buildBreedPath(from breedName: String) -> String {
        let components = breedName.lowercased().components(separatedBy: " ")
        
        if components.count == 2 {
            // For "afghan hound" format, build as "hound/afghan"
            let subBreed = components[0]
            let mainBreed = components[1]
            return "\(mainBreed)/\(subBreed)"
        } else {
            // For single breed names, use directly
            return breedName.lowercased()
        }
    }
    
    /// Clears the API response cache
    func clearCache() {
        responseCache.removeAllObjects()
    }

}

// MARK: - Mock Service for Testing

/// Mock implementation for testing
class MockDogAPIService: DogAPIServiceProtocol {
    var shouldFail = false
    
    var mockBreeds: [Breed] = [
        Breed(name: "labrador"),
        Breed(name: "golden retriever"),
        Breed(name: "german shepherd"),
        Breed(name: "bulldog")
    ]
    
    var mockImageURL = "https://images.dog.ceo/breeds/hound-afghan/n02088094_1007.jpg"
    
    /// Mock fetchAllBreeds implementation
    func fetchAllBreeds() async throws -> [Breed] {
        if shouldFail {
            throw DogAPIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: 500_000_000) // Simulate network delay
        return mockBreeds
    }
    
    /// Mock fetchFixedImage implementation
    func fetchFixedImage(for breed: Breed) async throws -> String {
        if shouldFail {
            throw DogAPIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network delay
        // Return deterministic URL based on breed name
        let breedHash = abs(breed.name.hashValue)
        return "https://images.dog.ceo/breeds/\(breed.name.lowercased())/fixed_\(breedHash).jpg"
    }
    
    /// Mock fetchFixedImages implementation
    func fetchFixedImages(for breed: Breed, count: Int = 6) async throws -> [String] {
        if shouldFail {
            throw DogAPIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network delay
        
        var images: [String] = []
        let breedHash = abs(breed.name.hashValue)
        
        // Generate deterministic URLs for testing consistency
        for i in 0..<count {
            let imageIndex = breedHash + i * 37
            let imageURL = "https://images.dog.ceo/breeds/\(breed.name.lowercased())/fixed_\(imageIndex).jpg"
            images.append(imageURL)
        }
        
        return images
    }
    
    /// Mock fetchRandomImage implementation
    func fetchRandomImage(for breed: Breed) async throws -> String {
        if shouldFail {
            throw DogAPIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network delay
        return mockImageURL
    }
    
    /// Mock fetchRandomImage implementation
    func fetchRandomImage() async throws -> String {
        if shouldFail {
            throw DogAPIError.networkError(URLError(.notConnectedToInternet))
        }
        
        try await Task.sleep(nanoseconds: 300_000_000) // Simulate network delay
        return mockImageURL
    }
}
