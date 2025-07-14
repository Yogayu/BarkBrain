//
//  ImageCacheManager.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation
import UIKit
import CoreData

/// Image cache manager
@MainActor
class ImageCacheManager: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = ImageCacheManager()
    
    // MARK: - Properties
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: URLCache
    private let session: URLSession
    
    // MARK: - Configuration
    private let maxMemoryCacheSize = 100 * 1024 * 1024 // 100MB
    private let maxDiskCacheSize = 500 * 1024 * 1024   // 500MB
    
    private init() {
        // Configure memory cache
        memoryCache.totalCostLimit = maxMemoryCacheSize
        memoryCache.countLimit = 100
        
        // Configure disk cache
        diskCache = URLCache(
            memoryCapacity: 500 * 1024 * 1024,  // 500MB memory
            diskCapacity: maxDiskCacheSize,
            diskPath: "breed_images_cache"
        )
        
        // Configure URL session with cache
        let config = URLSessionConfiguration.default
        config.urlCache = diskCache
        config.requestCachePolicy = .returnCacheDataElseLoad
        session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Loads image for a breed entity
    func loadImage(for breed: BreedEntity, apiService: DogAPIService) async throws -> String {
        let cacheKey = "breed_\(breed.id)_image"
        
        // Check if we have a cached URL for this breed
        if let cachedURL = getCachedImageURL(for: cacheKey) {
            // Verify the cached image is still accessible
            if await isImageAccessible(url: cachedURL) {
                return cachedURL
            }
        }
        
        // Fetch new image URL
        let imageURL = try await apiService.fetchRandomImage(for: Breed(name: breed.name))
        
        // Cache the URL
        cacheImageURL(imageURL, for: cacheKey)
        
        // Preload the actual image data
        _ = try await loadImageData(from: imageURL)
        
        return imageURL
    }
    
    /// Gets cached image if available
    func getCachedImage(from url: String) -> UIImage? {
        let key = NSString(string: url)
        return memoryCache.object(forKey: key)
    }
    
    /// Preloads and caches image data from URL
    @discardableResult
    func loadImageData(from url: String) async throws -> UIImage {
        let key = NSString(string: url)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: key) {
            return cachedImage
        }
        
        // Load from network/disk cache
        guard let imageURL = URL(string: url) else {
            throw ImageCacheError.invalidURL
        }
        
        let (data, _) = try await session.data(from: imageURL)
        
        guard let image = UIImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        
        // Cache in memory
        let cost = data.count
        memoryCache.setObject(image, forKey: key, cost: cost)
        
        return image
    }
    
    /// Clears all cached data
    func clearCache() {
        memoryCache.removeAllObjects()
        diskCache.removeAllCachedResponses()
        UserDefaults.standard.removeObject(forKey: "cached_image_urls")
    }
    
    /// Gets cache size information
    func getCacheInfo() -> (memoryCount: Int, diskSize: Int) {
        let memoryCount = memoryCache.totalCostLimit
        let diskSize = diskCache.currentDiskUsage
        return (memoryCount, diskSize)
    }
    
    // MARK: - Private Methods
    
    private func getCachedImageURL(for key: String) -> String? {
        let urls = UserDefaults.standard.dictionary(forKey: "cached_image_urls") as? [String: String]
        return urls?[key]
    }
    
    private func cacheImageURL(_ url: String, for key: String) {
        var urls = UserDefaults.standard.dictionary(forKey: "cached_image_urls") as? [String: String] ?? [:]
        urls[key] = url
        UserDefaults.standard.set(urls, forKey: "cached_image_urls")
    }
    
    private func isImageAccessible(url: String) async -> Bool {
        guard let imageURL = URL(string: url) else { return false }
        
        var request = URLRequest(url: imageURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        
        do {
            let (_, response) = try await session.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}

// MARK: - Cache Errors

enum ImageCacheError: Error, LocalizedError {
    case invalidURL
    case invalidImageData
    case cacheWriteError
    case cacheReadError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid image URL"
        case .invalidImageData:
            return "Invalid image data"
        case .cacheWriteError:
            return "Failed to write to cache"
        case .cacheReadError:
            return "Failed to read from cache"
        }
    }
}
