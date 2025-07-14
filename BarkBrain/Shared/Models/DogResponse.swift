//
//  DogResponse.swift
//  BarkBrain
//
//  Created by YouXinyu on 2025/7/13.
//

import Foundation

// API Response Models

struct DogBreedsResponse: Codable {
    let message: [String: [String]]
    let status: String
}

struct DogImageResponse: Codable {
    let message: String
    let status: String
}

struct DogImagesResponse: Codable {
    let message: [String]
    let status: String
}


