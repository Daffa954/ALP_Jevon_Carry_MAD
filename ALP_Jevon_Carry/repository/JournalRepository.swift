////
////  JournalRepository.swift
////  ALP_Jevon_Carry
////
////  Created by Daffa Khoirul on 28/05/25.
////
//
//import Foundation
//import FirebaseDatabase
//
//class FirebaseJournalRepository {
//    private let ref: DatabaseReference
//    
//    init() {
//        self.ref = Database.database().reference().child("journals")
//    }
//    
//    func addJournal(_ journal: JournalModel, completion: @escaping (Bool) -> Void) {
//        guard let jsonData = try? JSONEncoder().encode(journal),
//              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
//            completion(false)
//            return
//        }
//        
//        ref.child(journal.id.uuidString).setValue(json) { error, _ in
//            completion(error == nil)
//        }
//    }
//    
//    func fetchAllJournals(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//
//            let fetchedJournals: [JournalModel] = value.compactMap { (_, journalData) in
//                guard let journalDict = journalData as? [String: Any],
//                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
//                      var journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
//                else {
//                    return nil
//                }
//
//                if journal.userID == userID {
//                    journal.id = UUID()
//                    return journal
//                } else {
//                    return nil
//                }
//            }
//
//            let sorted = fetchedJournals.sorted { $0.date > $1.date }
//            completion(sorted)
//        }
//    }
//
//    func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                completion([])
//                return
//            }
//
//            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//            let calendar = Calendar.current
//
//            let journalsThisWeek: [JournalModel] = value.compactMap { (_, journalData) in
//                guard let journalDict = journalData as? [String: Any],
//                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
//                      var journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
//                else {
//                    return nil
//                }
//
//                if journal.userID == userID && journal.date >= oneWeekAgo {
//                    journal.id = UUID()
//                    return journal
//                } else {
//                    return nil
//                }
//            }
//
//            let groupedByDate = Dictionary(grouping: journalsThisWeek) {
//                calendar.startOfDay(for: $0.date)
//            }
//
//            let averagedJournals: [JournalModel] = groupedByDate.map { (date, journals) in
//                let averageScore = journals.map { Double($0.score) }.reduce(0, +) / Double(journals.count)
//
//                return JournalModel(
//                    id: UUID(),
//                    title: "Rata-rata hari \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))",
//                    date: date,
//                    description: "Rata-rata dari \(journals.count) jurnal",
//                    emotion: "Mixed",
//                    score: Int(averageScore.rounded()),
//                    userID: userID
//                )
//            }
//
//            let sorted = averagedJournals.sorted { $0.date < $1.date }
//            completion(sorted)
//        }
//    }
//}
//
//
//  JournalRepository.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 28/05/25.
//

import Foundation
import FirebaseDatabase

class FirebaseJournalRepository {
    private let ref: DatabaseReference
    
    init() {
        self.ref = Database.database().reference().child("journals")
    }
    
    func addJournal(_ journal: JournalModel, completion: @escaping (Bool) -> Void) {
        guard let jsonData = try? JSONEncoder().encode(journal),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("Error: Failed to encode journal to JSON.")
            completion(false)
            return
        }
        
        // Menggunakan journal.id.uuidString sebagai kunci di Firebase
        ref.child(journal.id.uuidString).setValue(json) { error, _ in
            if let error = error {
                print("Error adding journal to Firebase: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchAllJournals(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        // Mengamati single event untuk mengambil data sekali
        // order(byChild: "userID") dan equal(to: userID) akan lebih efisien jika data besar
        // Namun, jika struktur 'journals' Anda adalah root dan childnya langsung ID, maka
        // Anda mungkin perlu iterasi secara lokal seperti saat ini.
        ref.observeSingleEvent(of: .value) { snapshot in
            // Guard untuk memastikan snapshot memiliki nilai dan bisa di-cast ke [String: Any]
            guard let value = snapshot.value as? [String: Any] else {
                print("No journals found or invalid data format for all journals.")
                completion([])
                return
            }

            var fetchedJournals: [JournalModel] = []
            
            // Iterasi melalui setiap entri jurnal di snapshot
            for (_, journalData) in value {
                guard let journalDict = journalData as? [String: Any] else {
                    print("Warning: Invalid journal data format encountered.")
                    continue // Lanjutkan ke jurnal berikutnya jika format salah
                }
                
                // Konversi dictionary ke Data JSON untuk decoding
                guard let jsonData = try? JSONSerialization.data(withJSONObject: journalDict) else {
                    print("Warning: Failed to convert journal dictionary to JSON data.")
                    continue
                }
                
                // Dekode JSON Data ke JournalModel
                guard let journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData) else {
                    print("Warning: Failed to decode JournalModel from JSON data.")
                    continue
                }

                // Filter berdasarkan userID
                if journal.userID == userID {
                    // PENTING: Hapus baris 'journal.id = UUID()'.
                    // ID seharusnya sudah benar dari hasil decode.
                    fetchedJournals.append(journal)
                }
            }

            // Urutkan jurnal berdasarkan tanggal, terbaru duluan
            let sorted = fetchedJournals.sorted { $0.date > $1.date }
            completion(sorted)
        }
    }

//    func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
//        ref.observeSingleEvent(of: .value) { snapshot in
//            guard let value = snapshot.value as? [String: Any] else {
//                print("No journals found or invalid data format for journals this week.")
//                completion([])
//                return
//            }
//
//            let calendar = Calendar.current
//            // Tentukan batas awal untuk "minggu ini" (7 hari ke belakang dari sekarang)
//            // Ini akan mencakup jurnal yang dibuat dari waktu ini 7 hari yang lalu hingga sekarang.
//            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
//
//            var journalsInCurrentRange: [JournalModel] = []
//            
//            for (_, journalData) in value {
//                guard let journalDict = journalData as? [String: Any],
//                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
//                      let journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
//                else {
//                    print("Warning: Invalid journal data format encountered for weekly journals.")
//                    continue
//                }
//
//                // Filter berdasarkan userID dan tanggal (>= 7 hari yang lalu)
//                if journal.userID == userID && journal.date >= sevenDaysAgo {
//                    // PENTING: Hapus baris 'journal.id = UUID()'.
//                    // ID seharusnya sudah benar dari hasil decode.
//                    journalsInCurrentRange.append(journal)
//                }
//            }
//
//            // Pilihan 1: Mengembalikan jurnal individual dalam 7 hari terakhir (paling umum)
//            let sortedIndividualJournals = journalsInCurrentRange.sorted { $0.date > $1.date } // Urutkan terbaru duluan
//            completion(sortedIndividualJournals)
//            
//            /*
//            // Pilihan 2: Jika Anda memang ingin mengembalikan RATA-RATA SKOR per hari:
//            let groupedByDate = Dictionary(grouping: journalsInCurrentRange) {
//                calendar.startOfDay(for: $0.date)
//            }
//
//            let averagedJournals: [JournalModel] = groupedByDate.map { (date, journals) in
//                let averageScore = journals.map { Double($0.score) }.reduce(0, +) / Double(journals.count)
//
//                return JournalModel(
//                    id: UUID(), // ID baru untuk model rata-rata (ini OK karena ini model buatan)
//                    title: "Rata-rata hari \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))",
//                    date: date,
//                    description: "Rata-rata dari \(journals.count) jurnal",
//                    emotion: "Mixed", // Atau emosi yang paling dominan jika ada logika untuk itu
//                    score: Int(averageScore.rounded()),
//                    userID: userID
//                )
//            }
//
//            let sortedAveraged = averagedJournals.sorted { $0.date < $1.date } // Urutkan tertua duluan untuk grafik
//            completion(sortedAveraged)
//            */
//        }
    func fetchJournalsThisWeek(for userID: String, completion: @escaping ([JournalModel]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("No journals found or invalid data format for journals this week.")
                completion([])
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            
            // Dapatkan awal minggu dari tanggal saat ini
            // Contoh: Jika hari ini Kamis, 5 Juni, ini akan menjadi Senin, 2 Juni (jika minggu dimulai hari Senin)
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
                print("Failed to calculate start of the week.")
                completion([])
                return
            }
            
            // Akhir dari minggu adalah 'now' (hingga saat ini), atau Anda bisa menghitung akhir hari terakhir di minggu tersebut.
            // Untuk "hanya minggu ini dan tidak setelahnya", kita batasi hingga 'now'.
            let endOfWeek = now // Membatasi hingga waktu saat ini di minggu ini
            
            var journalsThisWeek: [JournalModel] = []
            
            for (_, journalData) in value {
                guard let journalDict = journalData as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: journalDict),
                      let journal = try? JSONDecoder().decode(JournalModel.self, from: jsonData)
                else {
                    print("Warning: Invalid journal data format encountered for weekly journals.")
                    continue
                }
                
                // Filter berdasarkan userID DAN pastikan tanggal jurnal berada dalam rentang startOfWeek dan endOfWeek (hingga sekarang)
                if journal.userID == userID && journal.date >= startOfWeek && journal.date <= endOfWeek {
                    journalsThisWeek.append(journal)
                }
            }
            
            // Urutkan jurnal berdasarkan tanggal, terbaru duluan
            let sortedIndividualJournals = journalsThisWeek.sorted { $0.date > $1.date }
            completion(sortedIndividualJournals)
        }
    }
}
