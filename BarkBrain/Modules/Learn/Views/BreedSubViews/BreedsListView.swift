//
//  BreedsListView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var sortOption: FilterView.SortOption = .name
    @State private var isPreloadingImages = false
    
    private let imagePreloadingManager = ImagePreloadingManager.shared

    // Fetch breeds from CoreData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \BreedEntity.displayName, ascending: true)],
        animation: .default)
    private var breeds: FetchedResults<BreedEntity>
    
    @State private var cachedFilteredBreeds: [BreedEntity] = []
    @State private var lastFilterKey = ""
    
    var categories: [String] {
        let allCategories = Array(Set(breeds.map { $0.category })).sorted()
        return ["All"] + allCategories
    }
    
    var filteredBreeds: [BreedEntity] {
        let currentFilterKey = "\(selectedCategory)_\(searchText)_\(sortOption.rawValue)"
        
        if currentFilterKey == lastFilterKey && !cachedFilteredBreeds.isEmpty {
            return cachedFilteredBreeds
        }
        
        var filtered = Array(breeds)
        
        // Filter by category
        if selectedCategory != "All" {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { breed in
                breed.displayName.localizedCaseInsensitiveContains(searchText) ||
                breed.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortOption {
        case .name:
            filtered.sort { $0.displayName < $1.displayName }
        case .category:
            filtered.sort { $0.category < $1.category }
        case .learned:
            filtered.sort { $0.isLearned && !$1.isLearned }
        }
        
        DispatchQueue.main.async {
            cachedFilteredBreeds = filtered
            lastFilterKey = currentFilterKey
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                FilterView(
                    searchText: $searchText,
                    selectedCategory: $selectedCategory,
                    sortOption: $sortOption,
                    categories: categories,
                    filteredCount: filteredBreeds.count
                )
                
                if filteredBreeds.isEmpty {
                    EmptyStateView(selectedCategory: $selectedCategory)
                } else {
                    List {
                        ForEach(filteredBreeds, id: \.objectID) { breed in
                            NavigationLink {
                                BreedDetailView(breed: breed)
                                    .onAppear {
                                        DataManager.shared.markBreedAsLearned(breed.id)
                                    }
                            } label: {
                                BreedRowContent(breed: breed) {}
                            }
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.white.opacity(0.8))
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                            )
                            .listRowSeparator(.hidden)
                            .onAppear {
                                imagePreloadingManager.preloadNearbyImages(for: breed, in: filteredBreeds)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Dog Breed Wiki")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search breeds...")
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Use ImagePreloadingManager for bulk preloading
                imagePreloadingManager.startBulkPreloading(for: filteredBreeds)
            }
            .onChange(of: selectedCategory) { _, newCategory in
                // Preload images for newly selected category
                imagePreloadingManager.preloadForCategory(newCategory, breeds: Array(breeds))
            }
            .onDisappear {
                // Cancel preloading when view disappears to conserve resources
                imagePreloadingManager.cancelAllPreloading()
            }
        }
    }
}

#Preview {
    BreedsListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
