//
//  CachedAsyncImage.swift
//  BarkBrain
//
//  Created by 游薪渝 on 7/13/25.
//

import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: String
    let cache: ImageCacheManager
    let content: (Image) -> Content
    let placeholder: () -> Placeholder
    
    @State private var cachedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                content(Image(uiImage: cachedImage))
            } else {
                placeholder()
                    .task {
                        await loadImage()
                    }
            }
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
            print("Failed to load cached image: \(error)")
        }
        isLoading = false
    }
}
