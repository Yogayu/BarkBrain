//
//  LearnView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI
import CoreData

struct LearnView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingBreedsList = false
    @State private var showingTraining = false
    @State private var selectedTrainingType: TrainingType = .imageToName
    
    // Fetch user progress
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var userProgress: FetchedResults<UserProgress>
    
    var currentProgress: UserProgress? {
        userProgress.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Stats
                    quickStatsView

                    // Main Actions
                    mainActionsView
                    
                    // Progress Overview
                    progressOverviewView
                    
                    Spacer(minLength: 50)
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
            .navigationTitle("Bark Brain")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $showingBreedsList) {
            BreedsListView()
        }
        .fullScreenCover(isPresented: $showingTraining) {
            TrainingView(trainingType: selectedTrainingType)
        }
    }
        
    // MARK: - Quick Stats
    
    private var quickStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Stats")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let progress = currentProgress {
                HStack(spacing: 20) {
                    QuickStatItem(
                        title: "Best Streak",
                        value: "\(progress.bestStreak)",
                        icon: "flame.fill",
                        color: .red
                    )
                    
                    QuickStatItem(
                        title: "Current Streak",
                        value: "\(progress.currentStreak)",
                        icon: "bolt.fill",
                        color: .yellow
                    )
                    
                    QuickStatItem(
                        title: "Total Questions",
                        value: "\(progress.totalQuestions)",
                        icon: "tray.circle.fill",
                        color: .blue
                    )
                }
            }
        }
    }
    
    // MARK: - Main Actions
    
    private var mainActionsView: some View {
        VStack(spacing: 16) {
            Text("Learning Method")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Browse Breeds Button
            Button {
                showingBreedsList = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Browse Breeds")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("View all breed details and add personal notes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue.opacity(0.3), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
            
            // Image to Name Training Button
            Button {
                selectedTrainingType = .imageToName
                showingTraining = true
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title2)
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Image to Name Training")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Select the correct breed name from image")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.green.opacity(0.3), lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Progress Overview
    
    private var progressOverviewView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            if let progress = currentProgress {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 150, maximum: 200), spacing: 12), count: 2), spacing: 12) {
                    ProgressCard(
                        title: "Learned",
                        value: Int(progress.learnedBreedsCount),
                        total: Int(progress.totalBreedsCount),
                        color: .blue,
                        icon: "book.fill"
                    )
                    
                    ProgressCard(
                        title: "Trained",
                        value: Int(progress.trainedBreedsCount),
                        total: Int(progress.totalBreedsCount),
                        color: .green,
                        icon: "dumbbell.fill"
                    )
                    
                    ProgressCard(
                        title: "Accuracy",
                        value: progress.totalQuestions > 0 ?
                            Int((Double(progress.correctAnswers) / Double(progress.totalQuestions)) * 100) : 0,
                        total: 100,
                        color: .orange,
                        icon: "target",
                        showAsPercentage: true
                    )
                    
                    ProgressCard(
                        title: "Study Streak",
                        value: Int(progress.consecutiveStudyDays),
                        total: nil,
                        color: .purple,
                        icon: "calendar",
                        unit: "days"
                    )
                }
            } else {
                Text("Loading progress...")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LearnView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
