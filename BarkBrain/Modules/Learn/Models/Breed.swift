//
//  Breed.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/14.
//

import Foundation

struct Breed: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    
    init(name: String) {
        self.name = name
        self.displayName = name.capitalized.replacingOccurrences(of: "_", with: " ")
    }
}
