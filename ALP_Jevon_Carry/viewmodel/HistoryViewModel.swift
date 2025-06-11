//
//  HistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 28/05/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase

class HistoryViewModel: ObservableObject {
    @Published var historyList: [HistoryModel] = []
    private let historyRepository: HistoryRepository
    
//    var openRouterService: OpenRouterService
//    @Published var recommendations: [String] = []
//    @Published var errorMessage: String?
//    @Published var isLoading = false


    init(historyRepository: HistoryRepository = HistoryRepository()  /*, openRouterService: OpenRouterService = OpenRouterService()*/) {
//        self.openRouterService = openRouterService
        self.historyRepository = historyRepository
    }
    
    func addHistory(_ history: HistoryModel) {
        self.historyRepository.addHistory(history) { success in
            if success {
                print("berhasil")
            } else {
                print("gagal")
            }
        }
    }
    
    func fetchHistory(userID: String) {
        historyRepository.fetchAllHistory(for: userID) { [weak self] history in
            DispatchQueue.main.async {
                self?.historyList = history
            }
        }
    }
    
//    func getRecommendations(_ history: HistoryModel) {
//        guard !history.summary.isEmpty else { return }
//        
//        isLoading = true
//        errorMessage = nil
//        
//        Task {
//            do {
//                let userPrompt = """
//                 You are a helpful activity recommendation assistant. 
//                 Return exactly 3 activity recommendations based on PHQ-9 or GAD-7 Assestment.
//                 This the classification for both score :
//                 For PHQ-9 : 
//                    case 0...4: return "Minimal or no depression"
//                    case 5...9: return "Mild depression"
//                    case 10...14: return "Moderate depression"
//                    case 15...19: return "Moderately severe depression"
//                    more than 19: return "Severe depression"
//                 For GAD-7 :
//                    case 0...4: return "Minimal anxiety"
//                    case 5...9: return "Mild anxiety"
//                    case 10...14: return "Moderate anxiety"
//                    more than 14: return "Severe anxiety"
//                 Only respond with valid JSON in this exact format:
//                 {
//                   "recommendation": ["Activity 1", "Activity 2", "Activity 3"]
//                 }
//                 The Assestment format is : \(history.type)
//                 The Assestment score is : \(history.totalScore)
//                 The Summary is: \(history.summary)
//                 """
//                let activities = try await openRouterService.getActivityRecommendations(prompt: userPrompt)
//                DispatchQueue.main.async {
//                    self.recommendations = activities
//                    self.isLoading = false
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription
//                    self.isLoading = false
//                }
//            }
//        }
//    }
    
}
