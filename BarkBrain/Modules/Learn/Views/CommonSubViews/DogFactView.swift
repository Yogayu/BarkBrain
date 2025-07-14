//
//  DogFactView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct DogFactView: View {
    let dogFact: DogFact
    let onDismiss: () -> Void
    
    @State private var showContent = false
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            VStack(spacing: 20) {
                // Header with animated emoji
                VStack(spacing: 12) {
                    Text(dogFact.emoji)
                        .font(.system(size: 60))
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .rotationEffect(.degrees(showContent ? 0 : 180))
                        .animation(.bouncy(duration: 0.8), value: showContent)
                    
                    Text("Did You Know?")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.3), value: showContent)
                }
                
                // Fact content
                VStack(spacing: 16) {
                    Text(dogFact.fact)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6).delay(0.5), value: showContent)
                    
                    Button("Continue") {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .opacity(showContent ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4).delay(0.8), value: showContent)
                }
                
                // Sparkle effects
                sparkleEffects
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 32)
            .scaleEffect(showContent ? 1.0 : 0.8)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showContent)
        }
        .onAppear {
            showContent = true
            startSparkleAnimation()
            
            // Auto-dismiss after 8 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
                onDismiss()
            }
        }
    }
    
    private var sparkleEffects: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkle")
                    .foregroundStyle(.yellow)
                    .font(.caption)
                    .offset(
                        x: cos(Double(index) * .pi / 4) * sparkleOffset,
                        y: sin(Double(index) * .pi / 4) * sparkleOffset
                    )
                    .opacity(showContent ? 0.8 : 0)
                    .animation(
                        .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: sparkleOffset
                    )
            }
        }
        .frame(width: 200, height: 200)
    }
    
    private func startSparkleAnimation() {
        withAnimation {
            sparkleOffset = 50
        }
    }
}

#Preview {
    DogFactView(dogFact: DogFact.random()) {
        print("Dismissed")
    }
}
