//
//  OpenRouterService.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//
//
import Foundation
//class OpenRouterService {
//    private let baseUrl = "https://openrouter.ai/api/v1"
//    private let apiKey = keyApi
//
//    func getActivityRecommendations(prompt: String, completion: @escaping (Result<[String], Error>) -> Void) {
//        guard let url = URL(string: "\(baseUrl)/chat/completions") else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
//            return
//        }
//
//        let userPrompt = """
//                    You are a helpful activity recommendation assistant.
//                     Your job is to return exactly 5 activity recommendations based on emotions. Never add explanation. Only respond in JSON with this structure:
//
//                    {
//                      "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
//                    }
//                    Only respond with valid JSON format.
//        Based on 8 basic plutchik emotions, which the emotion is \(prompt), suggest 5 activities.
//        Return only a valid JSON object in the format:
//
//        {
//          "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
//        }
//
//        No explanation. No extra text. No Markdown. Just pure JSON.
//        Do not include any other text or explanation.
//        """
//
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("Your-App-Name", forHTTPHeaderField: "HTTP-Referer")
//        request.setValue("your@email.com", forHTTPHeaderField: "X-Title")
//
//        let requestBody = OpenRouterRequest(
//            model: "deepseek/deepseek-chat:free",
//            messages: [
//                OpenRouterRequest.Message(role: "user", content: userPrompt)
//            ]
//        )
//
//        do {
//            request.httpBody = try JSONEncoder().encode(requestBody)
//        } catch {
//            completion(.failure(error))
//            return
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data else {
//                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
//                return
//            }
//
//            do {
//
//                // First try to decode the standard response
//                let decodedResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
//
//                if let errorMessage = decodedResponse.error?.message {
//                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
//                    return
//                }
//
//                guard let responseContent = decodedResponse.choices.first?.message.content else {
//                    completion(.failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "No response content"])))
//                    return
//                }
//
//                // Try to parse the JSON array from the response
//                if let jsonData = responseContent.data(using: .utf8),
//                   let activityResponse = try? JSONDecoder().decode(ActivityRecommendationResponse.self, from: jsonData) {
//                    completion(.success(activityResponse.recommendation))
//                } else {
//                    // Fallback: Try to extract array from plain text response
//                    let activities = self.extractActivitiesFromText(responseContent)
//                    completion(.success(activities))
//                }
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
//
//    private func extractActivitiesFromText(_ text: String) -> [String] {
//        // Simple parsing for numbered list format
//        let lines = text.components(separatedBy: .newlines)
//        var activities: [String] = []
//
//        for line in lines {
//            if let activity = line.split(separator: ".").last?.trimmingCharacters(in: .whitespaces),
//               !activity.isEmpty {
//                activities.append(String(activity))
//                if activities.count >= 5 {
//                    break
//                }
//            }
//        }
//
//        return activities.isEmpty ? ["No specific activities found"] : activities
//    }
//
//}
class OpenRouterService {
    private let baseUrl = "https://openrouter.ai/api/v1"
    
    
    func getActivityRecommendations(prompt: String) async throws -> [String] {
        //prepare url
        guard let url = URL(string: "\(baseUrl)/chat/completions") else {
            throw URLError(.badURL)
        }
        
        let userPrompt = """
        You are a helpful activity recommendation assistant. 
        Return exactly 5 activity recommendations based on Plutchik emotions.
        Only respond with valid JSON in this exact format:
        {
          "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
        }
        The emotion is: \(prompt)
        """
        //setup http method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //setup header
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.setValue(keyApi, forHTTPHeaderField: "Authorization")
        request.setValue("Bearer \(keyApi)", forHTTPHeaderField: "Authorization")
        request.setValue("Your-App-Name", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("your@email.com", forHTTPHeaderField: "X-Title")
        
        let requestBody = OpenRouterRequest(
            model: "deepseek/deepseek-chat:free",
            messages: [
                Message(role: "user", content: userPrompt)
            ]
        )
        //kirim data ke htttp dan rubah ke JSON
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        //mengambil nilai respon data dari URL SEssion yaitu Data(JSON) dan URLResponse (Respons metadata): Ini berisi informasi tambahan tentang respons dari server, seperti status HTTP code (contoh: 200 OK, 404 Not Found), header respons, tipe konten, dan URL akhir.
        //Data akan disimpan data sedangkan URL  _
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Debug: Print raw response
        print(String(data: data, encoding: .utf8) ?? "No data")
        
        // MERUBAH RESPON JSON ke OpenRouter Response model
        let decodedResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        //pengecekan proses decode
        if let error = decodedResponse.error {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.message])
        }
        
        guard let responseContent = decodedResponse.choices?.first?.message.content else {
            throw NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No response content"])
        }
        
        // Parse the JSON content from the message
        guard let jsonData = responseContent.data(using: .utf8) else {
            throw NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert content to data"])
        }
        
        do {
            let activityResponse = try JSONDecoder().decode(ActivityRecommendationResponse.self, from: jsonData)
            return activityResponse.recommendation
        } catch {
            print("Decoding error: \(error)")
            throw NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse recommendations: \(error.localizedDescription)"])
        }
    }
}
