//
//  BreedUserNotes.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct BreedUserNotes: View {
    let breed: BreedEntity
    @Binding var userNotes: String
    @Binding var isEditingNotes: Bool
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("My Notes")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    isEditingNotes.toggle()
                    if !isEditingNotes {
                        onSave()
                    }
                } label: {
                    Text(isEditingNotes ? "Done" : "Edit")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            if isEditingNotes {
                TextEditor(text: $userNotes)
                    .frame(minHeight: 100)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                    }
            } else {
                if userNotes.isEmpty {
                    Text("Tap edit to add your learning notes...")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                } else {
                    Text(userNotes)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#Preview {
    @State var notes = "This is a test note"
    @State var isEditing = false
    
    let context = PersistenceController.preview.container.viewContext
    let sampleBreed = BreedEntity(context: context)
    sampleBreed.id = UUID().uuidString
    sampleBreed.name = "golden retriever"
    sampleBreed.displayName = "Golden Retriever"
    
    return BreedUserNotes(
        breed: sampleBreed,
        userNotes: $notes,
        isEditingNotes: $isEditing,
        onSave: {}
    )
    .padding()
}