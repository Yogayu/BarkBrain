//
//  BreedDetailedInfo.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedDetailedInfo: View {
    let breed: BreedEntity
    @State private var showingFullCharacteristics = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Breed Characteristics")
                .font(.title2)
                .fontWeight(.bold)
            
            if let characteristics = breed.characteristics, !characteristics.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(showingFullCharacteristics ? characteristics : String(characteristics.prefix(150)))
                        .font(.body)
                        .lineLimit(showingFullCharacteristics ? nil : 3)
                    
                    if characteristics.count > 150 {
                        Button {
                            withAnimation {
                                showingFullCharacteristics.toggle()
                            }
                        } label: {
                            Text(showingFullCharacteristics ? "Show Less" : "Show More")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            } else {
                Text("No detailed information available")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
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
    sampleBreed.characteristics = "Golden Retrievers are friendly, intelligent, and devoted dogs that are known for their patience with children and love of water. They make excellent family pets and are very trainable."
    
    return BreedDetailedInfo(breed: sampleBreed)
        .padding()
}
