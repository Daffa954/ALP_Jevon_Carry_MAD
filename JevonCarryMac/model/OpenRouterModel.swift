//
//  OpenRouterModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//

import Foundation
struct OpenRouterRequest: Codable {
    let model: String
    let messages: [Message]
    
   
}
struct Message: Codable {
    let role: String
    let content: String
}

struct OpenRouterResponse: Codable {
    let choices: [Choice]?
    let error: ErrorResponse?
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
    
    struct ErrorResponse: Codable {
        let message: String
    }
}

struct ActivityRecommendationResponse: Codable {
    let recommendation: [String]
    
}

