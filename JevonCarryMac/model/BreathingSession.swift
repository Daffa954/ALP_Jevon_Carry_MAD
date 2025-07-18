//
//  BreathingSession.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// MARK: - BreathingSession.swift
// Purpose: Defines the data structure for a breathing session, focusing on timing.
import Foundation
import Firebase

// Represents a single breathing session record.
struct BreathingSession: Identifiable, Codable, Hashable {
    // A unique identifier for the session, generated locally.
    var id: String = UUID().uuidString
    // The ID of the user who performed this session.
    let userID: String
    // The date and time when the session started.
    let sessionDate: Date
    // The duration of the session in seconds.
    var duration: TimeInterval

    // Convenience initializer
    init(userID: String, sessionDate: Date, duration: TimeInterval) {
        self.id = UUID().uuidString
        self.userID = userID
        self.sessionDate = sessionDate
        self.duration = duration
    }
    
    // Full initializer with ID
    init(id: String, userID: String, sessionDate: Date, duration: TimeInterval) {
        self.id = id
        self.userID = userID
        self.sessionDate = sessionDate
        self.duration = duration
    }

    // CodingKeys for mapping to Firebase (optional if names match).
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case sessionDate
        case duration
    }
}

