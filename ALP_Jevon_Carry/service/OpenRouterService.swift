//
//  OpenRouterService.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//
//
import Foundation

class OpenRouterService {
    private let baseUrl = "https://openrouter.ai/api/v1"
    
    
    func getActivityRecommendations(prompt: String) async throws -> [String] {
        //prepare url
        guard let url = URL(string: "\(baseUrl)/chat/completions") else {
            throw URLError(.badURL)
        }
        
        
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
                Message(role: "user", content: prompt)
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
        
        // Parsing konten JSON
        guard let jsonData = responseContent.data(using: .utf8) else {
            throw NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to convert content to data"])
        }
        //Merubah hasil parsing ke dalam list recomendations
        do {
            let activityResponse = try JSONDecoder().decode(ActivityRecommendationResponse.self, from: jsonData)
            return activityResponse.recommendations
        } catch {
            print("Decoding error: \(error)")
            throw NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse recommendations: \(error.localizedDescription)"])
        }
    }
}
