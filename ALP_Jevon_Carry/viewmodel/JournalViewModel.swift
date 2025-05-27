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
    private var ref: DatabaseReference
    private let openRouterService = OpenRouterService()
    @Published var recommendations: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    init() {
        self.result = JournalModel(
            title: "",
            date: Date(),
            description: "",
            emotion: "",
            score: 0
        )
        self.ref = Database.database().reference().child("journals")
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
    func analyzeEmotion(userID : String) {
        //call the coreML service
        let emotion = CoreMLService.shared.classifyEmotion(from: userInput)
        let score = scoreForEmotion(emotion) // tambahkan scoring
        DispatchQueue.main.async {
            self.result = JournalModel(
                title: emotion, date: Date(), description: self.userInput,
                emotion: emotion, score: score, userID: userID)
            self.emoticonSymbol = self.emoticon(for: emotion)
            self.getRecommendations()
            var addToDB = self.addJournal(journal: self.result)
            if addToDB {
                print( "berhasil")
            }else {
                print("gagal")
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
    
    func getRecommendations() {
        guard !result.emotion.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        recommendations = []
        
        openRouterService.getActivityRecommendations(prompt: result.emotion) { [weak self] result in
            DispatchQueue.main.async {
                //stop the loading
                self?.isLoading = false
                
                //send the result
                switch result {
                case .success(let activities):
                    self?.recommendations = activities
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func addJournal(journal : JournalModel)-> Bool{
        guard let jsonData = try? JSONEncoder().encode(journal),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            return false
        }
        
        //send to firebase
        ref.child(journal.id.uuidString).setValue(json)
        return true
    }
}
