//
//  FirebaseSessionHistoryRepository.swift
//  ALP_Jevon_Carry
//
//  Created by student on 30/05/25.
//

import Foundation
import FirebaseDatabase

class FirebaseSessionHistoryRepository {
    private let ref: DatabaseReference
    private var listenerHandle: DatabaseHandle?

    init() {
        self.ref = Database.database().reference().child("allBreathingSessions")
    }

    func fetchAllSessions(for userID: String, completion: @escaping ([BreathingSession]) -> Void) {
        ref.observeSingleEvent(of: .value) { snapshot in
            completion(Self.parseSessions(snapshot: snapshot, userID: userID))
        }
    }

    // Add live updates (listener)
    func startListening(for userID: String, onChange: @escaping ([BreathingSession]) -> Void) {
        // Remove any existing listener
        stopListening()
        listenerHandle = ref.observe(.value) { snapshot in
            onChange(Self.parseSessions(snapshot: snapshot, userID: userID))
        }
    }

    func stopListening() {
        if let handle = listenerHandle {
            ref.removeObserver(withHandle: handle)
            listenerHandle = nil
        }
    }

    // Helper for parsing
    private static func parseSessions(snapshot: DataSnapshot, userID: String) -> [BreathingSession] {
        guard let value = snapshot.value as? [String: [String: Any]] else { return [] }
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
        return sessions.sorted { $0.sessionDate > $1.sessionDate }
    }
}
