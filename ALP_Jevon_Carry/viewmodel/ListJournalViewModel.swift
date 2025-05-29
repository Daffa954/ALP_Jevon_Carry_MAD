//
//  ListJournalViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 27/05/25.
//

import Foundation
//
//  JournalViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 25/05/25.
//


import FirebaseDatabase

class ListJournalViewModel: ObservableObject {
    
    @Published var allJournalHistories: [JournalModel] = []
    @Published var allJournalThisWeek: [JournalModel] = []
    //    @Published var isLoading = false
    private let journalRepository: FirebaseJournalRepository
    
    init(journalRepository: FirebaseJournalRepository = FirebaseJournalRepository()) {
        
        self.journalRepository = journalRepository
    }
    func fetchAllJournal(userID: String) {
        
        journalRepository.fetchAllJournals(for: userID) { [weak self] journals in
            DispatchQueue.main.async {
                self?.allJournalHistories = journals
            }
        }
    }
    
    func fetchJournalThisWeek(userID: String) {
        
        journalRepository.fetchJournalsThisWeek(for: userID) { [weak self] journals in
            DispatchQueue.main.async {
                self?.allJournalThisWeek = journals
            }
        }
    }
}
