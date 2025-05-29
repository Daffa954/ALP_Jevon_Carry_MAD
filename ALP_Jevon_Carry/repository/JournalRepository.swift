//
//  JournalRepository.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 28/05/25.
//

import Foundation
import FirebaseDatabase

class JournalRepository {
    private let ref: DatabaseReference
    
    init() {
        self.ref = Database.database().reference().child("journals")
    }
    
    func addJournal(_ journal: JournalModel, completion: @escaping (Bool) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(journal),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            completion(false)
            return
        }
        
        ref.child(journal.id.uuidString).setValue(json) { error, _ in
            completion(error == nil)
        }
    }
    
    func fetchAllJournals(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            let fetchedJournals: [JournalModel] = value.compactMap { (_, journalData) in
                guard let journalDict = journalData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
                      var journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
                else {
                    return nil
                }

                if journal.userID == userID {
                    journal.id = UUID()
                    return journal
                } else {
                    return nil
                }
            }

            let sorted = fetchedJournals.sorted { $0.date > $1.date }
            completion(sorted)
        }
    }

    func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion([])
                return
            }

            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            let calendar = Calendar.current

            let journalsThisWeek: [JournalModel] = value.compactMap { (_, journalData) in
                guard let journalDict = journalData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
                      var journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
                else {
                    return nil
                }

                if journal.userID == userID && journal.date >= oneWeekAgo {
                    journal.id = UUID()
                    return journal
                } else {
                    return nil
                }
            }

            let groupedByDate = Dictionary(grouping: journalsThisWeek) {
                calendar.startOfDay(for: $0.date)
            }

            let averagedJournals: [JournalModel] = groupedByDate.map { (date, journals) in
                let averageScore = journals.map { Double($0.score) }.reduce(0, +) / Double(journals.count)

                return JournalModel(
                    id: UUID(),
                    title: "Rata-rata hari \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))",
                    date: date,
                    description: "Rata-rata dari \(journals.count) jurnal",
                    emotion: "Mixed",
                    score: Int(averageScore.rounded()),
                    userID: userID
                )
            }

            let sorted = averagedJournals.sorted { $0.date < $1.date }
            completion(sorted)
        }
    }
}

