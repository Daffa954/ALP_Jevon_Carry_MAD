//
//  FirebaseBreathingRepository.swift
//  ALP_Jevon_Carry
//
//  Created by student on 30/05/25.
//

import Foundation
import FirebaseDatabase

class FirebaseBreathingRepository {
    private let ref: DatabaseReference

    init() {
        self.ref = Database.database().reference().child("allBreathingSessions")
    }

    func addSession(_ session: BreathingSession, completion: @escaping (Bool) -> Void) {
        let dict: [String: Any] = [
            "id": session.id,
            "userID": session.userID,
            "sessionDate": session.sessionDate.timeIntervalSince1970,
            "duration": session.duration
        ]
        ref.child(session.id).setValue(dict) { error, _ in
            completion(error == nil)
        }
    }

    func fetchAllSessions(for userID: String, completion: @escaping ([BreathingSession]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }
            let sessions: [BreathingSession] = value.compactMap { (id, dict) in
                guard let sessionUserID = dict["userID"] as? String,
                      sessionUserID == userID,
                      let duration = dict["duration"] as? TimeInterval
                else { return nil }
                let date: Date
                if let ts = dict["sessionDate"] as? TimeInterval {
                    date = Date(timeIntervalSince1970: ts)
                } else {
                    date = Date()
                }
                return BreathingSession(id: id, userID: sessionUserID, sessionDate: date, duration: duration)
            }
            let sorted = sessions.sorted { $0.sessionDate > $1.sessionDate }
            completion(sorted)
        }
    }

    func fetchSessionsThisWeek(for userID: String, completion: @escaping ([BreathingSession]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
            let sessions: [BreathingSession] = value.compactMap { (id, dict) in
                guard let sessionUserID = dict["userID"] as? String,
                      sessionUserID == userID,
                      let duration = dict["duration"] as? TimeInterval
                else { return nil }
                let date: Date
                if let ts = dict["sessionDate"] as? TimeInterval {
                    date = Date(timeIntervalSince1970: ts)
                } else {
                    date = Date()
                }
                guard date >= oneWeekAgo else { return nil }
                return BreathingSession(id: id, userID: sessionUserID, sessionDate: date, duration: duration)
            }
            let sorted = sessions.sorted { $0.sessionDate > $1.sessionDate }
            completion(sorted)
        }
    }
}
