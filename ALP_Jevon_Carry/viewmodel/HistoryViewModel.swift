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
    init(historyRepository: HistoryRepository = HistoryRepository()) {
        
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
    
    
    
}
