//
//  OpenRouterModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//

import Foundation

//
//  OpenRouterModel.swift
//  CobaLibrary
//
//  Created by Daffa Khoirul on 29/04/25.
//

import Foundation
struct OpenRouterRequest: Codable {
    let model: String
    let messages: [Message]
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

struct OpenRouterResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
    let error: ErrorResponse?
    
    struct ErrorResponse: Codable {
        let message: String
    }
}

// Add this new model for structured array responses
struct ActivityRecommendationResponse: Codable {
    let recommendation: [String]
}

