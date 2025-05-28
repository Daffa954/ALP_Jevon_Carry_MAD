//
//  HistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 28/05/25.
//

import Foundation

class HistoryViewModel: ObservableObject {
    @Published var historyList: [HistoryModel] = []
    
    func addHistory(_ history: HistoryModel) {
        historyList.insert(history, at: 0)
    }
}
