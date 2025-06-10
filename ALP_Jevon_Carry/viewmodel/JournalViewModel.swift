//
//  JournalViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 25/05/25.
//

import Foundation
import FirebaseDatabase

class JournalViewModel: ObservableObject {
    @Published var userInput = ""
    @Published var result : JournalModel
    @Published var emoticonSymbol = ""
    var openRouterService: OpenRouterService
    @Published var recommendations: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let journalRepository: FirebaseJournalRepository
    var coreMLService: CoreMLService
    
    
    init(journalRepository: FirebaseJournalRepository = FirebaseJournalRepository(),
         openRouterService: OpenRouterService = OpenRouterService(),
         coreMLService: CoreMLService = CoreMLService.shared) {
        self.result = JournalModel(
            title: "",
            date: Date(),
            description: "",
            emotion: "",
            score: 0
        )
        self.journalRepository = journalRepository
        self.openRouterService = openRouterService
        self.coreMLService = coreMLService
    }
    private func emoticon(for emotion: String) -> String {
        switch emotion.lowercased() {
        case "joy": return "😊"
        case "trust": return "🤝"
        case "fear": return "😨"
        case "surprise": return "😲"
        case "sadness": return "😢"
        case "disgust": return "🤢"
        case "anger": return "😠"
        case "anticipation": return "🤔"
        default: return "❓"
        }
    }
    
    func analyzeEmotion(userID: String) {
        let emotion = CoreMLService.shared.classifyEmotion(from: userInput)
        let score = scoreForEmotion(emotion)
        
        DispatchQueue.main.async {
            self.result = JournalModel(
                title: emotion,
                date: Date(),
                description: self.userInput,
                emotion: emotion,
                score: score,
                userID: userID
            )
            self.emoticonSymbol = self.emoticon(for: emotion)
            self.getRecommendations()
            
            self.journalRepository.addJournal(self.result) { success in
                if success {
                    print("berhasil")
                } else {
                    print("gagal")
                }
            }
            
        }
    }
    func scoreForEmotion(_ emotion: String) -> Int {
        switch emotion.lowercased() {
        case "anger": return 10
        case "fear": return 9
        case "disgust": return 8
        case "sadness": return 7
        case "surprise": return 6
        case "anticipation": return 5
        case "trust": return 3
        case "joy": return 1
        default: return 5 // netral
        }
    }
    
//    func getRecommendations() {
//        guard !result.emotion.isEmpty else { return }
//        
//        isLoading = true
//        errorMessage = nil
//        recommendations = []
//        
//        openRouterService.getActivityRecommendations(prompt: result.emotion) { [weak self] result in
//            DispatchQueue.main.async {
//                //stop the loading
//                self?.isLoading = false
//                
//                //send the result
//                switch result {
//                case .success(let activities):
//                    self?.recommendations = activities
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
    
    func getRecommendations() {
        guard !result.emotion.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let userPrompt = """
                 You are a helpful activity recommendation assistant. 
                 Return exactly 5 activity recommendations based on Plutchik emotions.
                 Only respond with valid JSON in this exact format:
                 {
                   "recommendation": ["Activity 1", "Activity 2", "Activity 3", "Activity 4", "Activity 5"]
                 }
                 The emotion is: \(result.emotion)
                 """
                let activities = try await openRouterService.getActivityRecommendations(prompt: userPrompt)
                DispatchQueue.main.async {
                    self.recommendations = activities
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
