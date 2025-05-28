//
//  OpenRouterService.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//

import Foundation
class OpenRouterService {
    private let baseUrl = "https://openrouter.ai/api/v1"
    private let apiKey = keyApi
    
    func getActivityRecommendations(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: "\(baseUrl)/chat/completions") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Craft a prompt that forces JSON array response
        let systemPrompt = """
            You are a helpful activity recommendation assistant. 
             Your job is to return exactly 5 activity recommendations based on emotions. Never add explanation. Only respond in JSON with this structure:

            {
              "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
            }
            Only respond with valid JSON format.
            """
        
        let userPrompt = """
        Based on 8 basic plutchik emotions, which the emotion is \(prompt), suggest 5 activities. 
        Return only a valid JSON object in the format:

        {
          "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
        }

        No explanation. No extra text. No Markdown. Just pure JSON.
        Do not include any other text or explanation.
        """
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("Your-App-Name", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("your@email.com", forHTTPHeaderField: "X-Title")
        
        let requestBody = OpenRouterRequest(
            model: "deepseek/deepseek-chat:free",
            messages: [
                OpenRouterRequest.Message(role: "system", content: systemPrompt),
                OpenRouterRequest.Message(role: "user", content: userPrompt)
            ]
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                
                // First try to decode the standard response
                let decodedResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
                
                if let errorMessage = decodedResponse.error?.message {
                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                guard let responseContent = decodedResponse.choices.first?.message.content else {
                    completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No response content"])))
                    return
                }
                
                // Try to parse the JSON array from the response
                if let jsonData = responseContent.data(using: .utf8),
                   let activityResponse = try? JSONDecoder().decode(ActivityRecommendationResponse.self, from: jsonData) {
                    completion(.success(activityResponse.recommendation))
                } else {
                    // Fallback: Try to extract array from plain text response
                    let activities = self.extractActivitiesFromText(responseContent)
                    completion(.success(activities))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func extractActivitiesFromText(_ text: String) -> [String] {
        // Simple parsing for numbered list format
        let lines = text.components(separatedBy: .newlines)
        var activities: [String] = []
        
        for line in lines {
            if let activity = line.split(separator: ".").last?.trimmingCharacters(in: .whitespaces),
               !activity.isEmpty {
                activities.append(String(activity))
                if activities.count >= 5 {
                    break
                }
            }
        }
        
        return activities.isEmpty ? ["No specific activities found"] : activities
    }
    
}
