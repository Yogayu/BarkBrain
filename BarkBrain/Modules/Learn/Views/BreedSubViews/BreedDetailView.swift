//
//  BreedDetailView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedDetailView: View {
    let breed: BreedEntity
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var breedImages: [String] = []
    @State private var isLoadingImages = true
    @State private var currentImageIndex = 0
    @State private var userNotes = ""
    @State private var isEditingNotes = false
    
    private let apiService = DogAPIService()
    private let maxImages = 6
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Image carousel
                    BreedImageCarousel(
                        breedImages: $breedImages,
                        isLoadingImages: $isLoadingImages,
                        currentImageIndex: $currentImageIndex
                    )
                    
                    // Basic info
                    BreedBasicInfo(breed: breed)
                    
                    // Detailed information
                    BreedDetailedInfo(breed: breed)
                    
                    // User notes section
                    BreedUserNotes(
                        breed: breed,
                        userNotes: $userNotes,
                        isEditingNotes: $isEditingNotes,
                        onSave: saveNotes
                    )
                    
                    Spacer(minLength: 38)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.05), .green.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle(breed.displayName)
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadBreedImages()
            loadUserNotes()
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadBreedImages() async {
        isLoadingImages = true
        var images: [String] = []
            
        do {
            images = try await apiService.fetchFixedImages(for: Breed(name: breed.name), count: maxImages)
        } catch {
            print("Failed to load image: \(error)")
        }
    
        breedImages = images
        isLoadingImages = false
    }
    
    private func loadUserNotes() {
        userNotes = breed.userNotes ?? ""
    }
    
    private func saveNotes() {
        DataManager.shared.updateBreedNotes(breed.id, notes: userNotes)
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let sampleBreed = BreedEntity(context: context)
    sampleBreed.id = UUID().uuidString
    sampleBreed.name = "golden retriever"
    sampleBreed.displayName = "Golden Retriever"
    sampleBreed.category = "Sporting"
    sampleBreed.origin = "Scotland"
    sampleBreed.characteristics = "Golden Retrievers are friendly, intelligent, and devoted dogs that are known for their patience with children and love of water."
    sampleBreed.isLearned = true
    
    return BreedDetailView(breed: sampleBreed)
        .environment(\.managedObjectContext, context)
}
