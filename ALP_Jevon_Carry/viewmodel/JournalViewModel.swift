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
    @Published var result : JournalModel?
    @Published var emoticonSymbol = ""
    private var ref: DatabaseReference
    
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
    func analyzeEmotion() {
        let emotion = CoreMLService.shared.classifyEmotion(from: userInput)
        DispatchQueue.main.async {
            self.result = JournalModel(
                title: emotion, date: Date(), description: self.userInput,
                emotion: emotion, score: 0)
            self.emoticonSymbol = self.emoticon(for: emotion)
           
        }
    }
    
    func saveJournal() {
        let journal: [String: Any] = [
            "text": userInput,
            "emotion": result?.emotion ?? "",
        ]
        ref.childByAutoId().setValue(journal)
    }
}
