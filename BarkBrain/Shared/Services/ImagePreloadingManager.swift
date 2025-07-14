//
//  ImagePreloadingManager.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation
import CoreData

/// Image preloading manager
@MainActor
class ImagePreloadingManager: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = ImagePreloadingManager()
    
    // MARK: - Properties
    private let imageCache = ImageCacheManager.shared
    private let apiService = DogAPIService()
    private var isPreloadingActive = false
    private var preloadingTasks: [String: Task<Void, Never>] = [:]
    
    // MARK: - Configuration
    private let maxPreloadCount = 20
    private let preloadDelay: UInt64 = 100_000_000 // 0.1 seconds
    private let nearbyPreloadRange = 6
    private let preloadLookBack = 3
    private let preloadImageCount = 6 // Number of fixed images to preload per breed
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Starts bulk preloading for breeds
    func startBulkPreloading(for breeds: [BreedEntity]) {
        guard !isPreloadingActive else { return }
        
        isPreloadingActive = true
        
        Task {
            let breedsToPreload = Array(breeds.prefix(maxPreloadCount))
            
            for breed in breedsToPreload {
                guard !Task.isCancelled else { break }
                
                await preloadFixedImagesSafely(for: breed)
                try? await Task.sleep(nanoseconds: preloadDelay)
            }
            
            isPreloadingActive = false
        }
    }
    
    /// Preloads images for breeds near the currently visible item
    func preloadNearbyImages(for currentBreed: BreedEntity, in allBreeds: [BreedEntity]) {
        guard let currentIndex = allBreeds.firstIndex(where: { $0.objectID == currentBreed.objectID }) else {
            return
        }
        
        let startIndex = max(0, currentIndex - preloadLookBack)
        let endIndex = min(allBreeds.count - 1, currentIndex + nearbyPreloadRange)
        
        for index in startIndex...endIndex {
            let breed = allBreeds[index]
            
            // Skip if already preloading this breed
            guard preloadingTasks[breed.id] == nil else { continue }
            
            preloadingTasks[breed.id] = Task.detached(priority: .background) {
                await self.preloadFixedImagesSafely(for: breed)
                
                await MainActor.run {
                    self.preloadingTasks.removeValue(forKey: breed.id)
                }
            }
        }
    }
    
    /// Cancels all ongoing preloading operations
    func cancelAllPreloading() {
        isPreloadingActive = false
        
        for task in preloadingTasks.values {
            task.cancel()
        }
        preloadingTasks.removeAll()
    }
    
    /// Cancels preloading for a specific breed
    func cancelPreloading(for breedId: String) {
        preloadingTasks[breedId]?.cancel()
        preloadingTasks.removeValue(forKey: breedId)
    }
    
    // MARK: - Private Methods
    
    /// Safely preloads fixed images for a breed
    private func preloadFixedImagesSafely(for breed: BreedEntity) async {
        do {
            // Fetch fixed images for the breed
            let imageURLs = try await apiService.fetchFixedImages(
                for: Breed(name: breed.name), 
                count: preloadImageCount
            )
            
            // Preload each image data
            for imageURL in imageURLs {
                // Check if already cached to avoid redundant loading
                if imageCache.getCachedImage(from: imageURL) == nil {
                    do {
                        _ = try await imageCache.loadImageData(from: imageURL)
                    } catch {
                        // Silent failure for individual image - continue with others
                        print("Failed to preload image \(imageURL): \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            // Silent failure for preloading - not critical for user experience
            print("Preloading failed for breed \(breed.name): \(error.localizedDescription)")
        }
    }
    
    /// Legacy method - kept for backward compatibility
    @available(*, deprecated, message: "Use preloadFixedImagesSafely instead")
    private func preloadImageSafely(for breed: BreedEntity) async {
        do {
            _ = try await imageCache.loadImage(for: breed, apiService: apiService)
        } catch {
            // Silent failure for preloading - not critical for user experience
            print("Preloading failed for breed \(breed.name): \(error.localizedDescription)")
        }
    }
}

// MARK: - Preloading Strategy Extensions

extension ImagePreloadingManager {
    
    /// Advanced preloading strategy based on user behavior patterns
    func intelligentPreload(for breeds: [BreedEntity], anticipatingDirection: ScrollDirection = .down) {
        // Future enhancement: implement directional preloading based on scroll patterns
        // For now, use standard nearby preloading
        guard let firstBreed = breeds.first else { return }
        preloadNearbyImages(for: firstBreed, in: breeds)
    }
    
    /// Preloads images for a specific category
    func preloadForCategory(_ category: String, breeds: [BreedEntity]) {
        let categoryBreeds = breeds.filter { $0.category == category }
        startBulkPreloading(for: Array(categoryBreeds.prefix(10)))
    }
}

// MARK: - Supporting Types

enum ScrollDirection {
    case up, down, unknown
}
