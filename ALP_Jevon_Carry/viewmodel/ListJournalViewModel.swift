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
    func fetchAllJournal(userID: String) {
        ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                self.allJournalHistories = []
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
                    journal.id = UUID() // Jika `id` adalah UUID dan tidak tersimpan di Firebase
                    return journal
                } else {
                    return nil
                }
            }

            self.allJournalHistories = fetchedJournals.sorted(by: { $0.date > $1.date })
        }
    }

    func fetchJournalThisWeek(userID: String) {
        ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                self.allJournalThisWeek = []
                return
            }

            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()

            let calendar = Calendar.current

            // Ambil semua journal dalam 7 hari terakhir & milik user ini
            let journalsThisWeek: [JournalModel] = value.compactMap { (_, restData) in
                guard let restDict = restData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: restDict),
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

            // Kelompokkan berdasarkan tanggal (tanpa jam)
            let groupedByDate = Dictionary(grouping: journalsThisWeek) { journal in
                calendar.startOfDay(for: journal.date)
            }

            // Rata-rata score per hari
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

            // Urutkan berdasarkan tanggal
            self.allJournalThisWeek = averagedJournals.sorted(by: { $0.date < $1.date })
        }
    }

}
