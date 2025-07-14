//
//  BreedBasicInfo.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedBasicInfo: View {
    let breed: BreedEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Basic Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                if breed.isLearned {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Learned")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                InfoCard(
                    title: "Breed Group",
                    value: breed.category,
                    icon: "tag.fill",
                    color: .blue
                )
                
                InfoCard(
                    title: "Origin",
                    value: breed.origin ?? "Unknown",
                    icon: "globe",
                    color: .green
                )
            }
        }
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
    sampleBreed.isLearned = true
    
    return BreedBasicInfo(breed: sampleBreed)
        .padding()
}