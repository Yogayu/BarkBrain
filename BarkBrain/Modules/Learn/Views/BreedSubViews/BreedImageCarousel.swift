//
//  BreedImageCarousel.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct BreedImageCarousel: View {
    @Binding var breedImages: [String]
    @Binding var isLoadingImages: Bool
    @Binding var currentImageIndex: Int
    
    private let imageHeight: CGFloat = 250
    private let cornerRadius: CGFloat = 16
    private let imageCache = ImageCacheManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if isLoadingImages {
                loadingView
            } else if !breedImages.isEmpty {
                imageCarousel
                
                if breedImages.count > 1 {
                    imageCounter
                }
            } else {
                emptyStateView
            }
        }
        .onChange(of: breedImages) { _, newImages in
            // Preload all images when URLs are available
            if !newImages.isEmpty {
                preloadAllImages(urls: newImages)
            }
        }
    }
    
    // MARK: - Preloading Methods
    
    private func preloadAllImages(urls: [String]) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for url in urls {
                    group.addTask {
                        await preloadImage(url: url)
                    }
                }
            }
        }
    }
    
    private func preloadImage(url: String) async {
        do {
            // Check if already cached
            if imageCache.getCachedImage(from: url) != nil {
                return
            }
            
            // Preload image data
            _ = try await imageCache.loadImageData(from: url)
        } catch {
            // Silent failure for preloading
            print("Failed to preload image: \(error)")
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.15))
            .frame(height: imageHeight)
            .overlay {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.blue)
                    Text("Loading images...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
    }
    
    private var imageCarousel: some View {
        GeometryReader { geometry in
            TabView(selection: $currentImageIndex) {
                ForEach(Array(breedImages.enumerated()), id: \.offset) { index, imageURL in
                    SharedImageView(
                        url: imageURL,
                        cache: imageCache,
                        width: geometry.size.width,
                        height: imageHeight,
                        cornerRadius: cornerRadius
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .frame(height: imageHeight)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var imageCounter: some View {
        HStack(spacing: 8) {
            // Page dots indicator
            HStack(spacing: 6) {
                ForEach(0..<breedImages.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentImageIndex ? .blue : .gray.opacity(0.4))
                        .frame(width: 6, height: 6)
                        .scaleEffect(index == currentImageIndex ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: currentImageIndex)
                }
            }
            
            Spacer()
            
            // Numeric counter
            Text("\(currentImageIndex + 1) / \(breedImages.count)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .padding(.horizontal, 4)
    }
    
    private var emptyStateView: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.1))
            .frame(height: imageHeight)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.title2)
                        .foregroundStyle(.gray)
                    Text("No images available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            }
    }
}

// MARK: - Shared Image View Component

struct SharedImageView: View {
    let url: String
    let cache: ImageCacheManager
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            if let cachedImage = cachedImage {
                // Background blur effect
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: height)
                    .blur(radius: 20)
                    .clipped()
                
                // Main image
                Image(uiImage: cachedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: width, height: height)
                    .clipped()
            } else {
                // Background placeholder - matches blur background
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: width, height: height)
                    .blur(radius: 20)
                    .clipped()
                
                // Main placeholder - matches main image layout
                ZStack {
                    // Use same frame constraints as the actual image
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width, height: height)
                        .overlay {
                            VStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(1.1)
                                    .tint(.blue)
                                Text("Loading...")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
                .clipped()
            }
        }
        .background(Color.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .task {
            await loadImage()
        }
    }
    
    @MainActor
    private func loadImage() async {
        // Check memory cache first
        if let cached = cache.getCachedImage(from: url) {
            cachedImage = cached
            return
        }
        
        // Load from network/disk cache
        isLoading = true
        do {
            let image = try await cache.loadImageData(from: url)
            cachedImage = image
        } catch {
            print("Failed to load shared image: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    VStack(spacing: 32) {
        // Loading state
        BreedImageCarousel(
            breedImages: .constant([]),
            isLoadingImages: .constant(true),
            currentImageIndex: .constant(0)
        )
        
        // With images
        BreedImageCarousel(
            breedImages: .constant([
                "https://example.com/image1.jpg",
                "https://example.com/image2.jpg",
                "https://example.com/image3.jpg"
            ]),
            isLoadingImages: .constant(false),
            currentImageIndex: .constant(0)
        )
        
        // Empty state
        BreedImageCarousel(
            breedImages: .constant([]),
            isLoadingImages: .constant(false),
            currentImageIndex: .constant(0)
        )
    }
    .padding()
}
