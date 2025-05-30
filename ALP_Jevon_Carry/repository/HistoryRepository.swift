//
//  HistoryRepository.swift
//  ALP_Jevon_Carry
//
//  Created by student on 30/05/25.
//

import Foundation
import FirebaseDatabase

class HistoryRepository {
    private let ref: DatabaseReference
    
    init() {
        self.ref = Database.database().reference().child("quizHistory")
    }
    

    func addHistory(_ history: HistoryModel, completion: @escaping (Bool) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(history),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            completion(false)
            return
        }
        
        ref.child(history.id.uuidString).setValue(json) { error, _ in
            completion(error == nil)
        }
    }
    
    func fetchAllHistory(for userID: String, completion: @escaping ([HistoryModel]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            let fetchedHistory: [HistoryModel] = value.compactMap { (_, historyData) in
                guard let historyDict = historyData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: historyDict),
                      var history = try? JSONDecoder().decode(HistoryModel.self, from: jsonData)
                else {
                    return nil
                }

                if history.userID == userID {
                    history.id = UUID()
                    return history
                } else {
                    return nil
                }
            }

            let sorted = fetchedHistory.sorted { $0.date > $1.date }
            completion(sorted)
        }
    }

    
    
//    func fetchAllHistory(for userID: String, completion: @escaping ([HistoryModel]) -> Void) {
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//
//            let fetchedHistory: [HistoryModel] = value.compactMap { (_, historyData) in
//                guard let historyDict = historyData as? [String: Any],
//                      let jsonData = try? JSONSerialization.data(withJSONObject: historyDict),
//                      var history = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
//                else {
//                    return nil
//                }
//
//                if history.userID == userID {
//                    history.id = UUID()
//                    return history
//                } else {
//                    return nil
//                }
//            }
//
//            let sorted = fetchedHistory.sorted { $0.date > $1.date }
//            completion(sorted)
//        }
//    }
    
}
