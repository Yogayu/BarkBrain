//
//  TrainingLoadingView.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import SwiftUI

struct TrainingLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Preparing training questions...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    TrainingLoadingView()
}