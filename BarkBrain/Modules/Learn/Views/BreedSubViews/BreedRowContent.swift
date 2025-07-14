//
//  EnhancedBreedRowContent.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedRowContent: View {
    let breed: BreedEntity
    let onTap: () -> Void
    
    @State private var breedImageURL: String?
    @State private var isLoadingImage = true
    @State private var loadingTask: Task<Void, Never>?
    
    private let apiService = DogAPIService()
    private let imageCache = ImageCacheManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Breed image with caching
            Group {
                if let imageURLString = breedImageURL,
                   let imageURL = URL(string: imageURLString) {
                    CachedAsyncImage(url: imageURL.absoluteString, cache: imageCache) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } placeholder: {
                        placeholderView
                    }
                } else {
                    placeholderView
                }
            }
            
            // Breed info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(breed.displayName)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if breed.isLearned {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                
                Text(breed.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(.blue.opacity(0.1), in: Capsule())
                    .foregroundStyle(.blue)
                
                if let characteristics = breed.characteristics, !characteristics.isEmpty {
                    Text(characteristics)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadBreedImageIfNeeded()
        }
        .onDisappear {
            // 取消正在进行的任务
            loadingTask?.cancel()
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 60, height: 60)
            .overlay {
                if isLoadingImage {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "photo")
                        .foregroundStyle(.gray)
                }
            }
    }
    
    private func loadBreedImageIfNeeded() {
        // 如果已经有图片URL，不需要重新加载
        guard breedImageURL == nil else { return }
        
        // 取消之前的加载任务
        loadingTask?.cancel()
        
        isLoadingImage = true
        
        loadingTask = Task { @MainActor in
            do {
                let imageURL = try await imageCache.loadImage(for: breed, apiService: apiService)
                
                // 检查任务是否被取消
                guard !Task.isCancelled else { return }
                
                breedImageURL = imageURL
                isLoadingImage = false
                
            } catch {
                // 检查任务是否被取消
                guard !Task.isCancelled else { return }
                
                print("Failed to load fixed image for \(breed.name): \(error)")
                isLoadingImage = false
                
                // 如果固定图片加载失败，尝试使用随机图片作为最后的后备方案
                do {
                    let fallbackURL = try await apiService.fetchRandomImage(for: Breed(name: breed.name))
                    breedImageURL = fallbackURL
                } catch {
                    print("Failed to load fallback image: \(error)")
                }
            }
        }
    }
}

#Preview {
    // Create a preview with mock BreedEntity
    BreedRowContent(
        breed: {
            let breed = BreedEntity(context: PersistenceController.preview.container.viewContext)
            breed.id = "golden"
            breed.name = "golden"
            breed.displayName = "Golden Retriever"
            breed.category = "Sporting"
            breed.characteristics = "Friendly, intelligent, devoted"
            breed.isLearned = true
            return breed
        }(),
        onTap: {}
    )
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    .padding()
}
