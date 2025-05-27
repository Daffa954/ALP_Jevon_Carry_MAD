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
    private var ref: DatabaseReference
    @Published var allJournalHistories: [JournalModel] = []
    @Published var allJournalThisWeek: [JournalModel] = []
    @Published var isLoading = false
    init() {
        
        self.ref = Database.database().reference().child("journals")
    }
    
    func fetchJournalThisWeek(userID: String) {
        ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String : Any] else {
                self.allJournalThisWeek = []
                return
            }

            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

            self.allJournalThisWeek = value.compactMap { (_, restData) in
                guard let restDict = restData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: restDict),
                      var journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
                else {
                    return nil
                }

                // Filter by userID and date >= oneWeekAgo
                if journal.userID == userID && journal.date >= oneWeekAgo {
                    // Generate UUID if not included from Firebase
                    journal.id = UUID()
                    return journal
                } else {
                    return nil
                }
            }
        }
    }


}
