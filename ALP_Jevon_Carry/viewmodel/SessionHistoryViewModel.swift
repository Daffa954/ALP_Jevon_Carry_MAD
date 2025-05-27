//
//  SessionHistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// SessionHistoryViewModel.swift (Create this new file)
// Make sure to import Foundation, SwiftUI, FirebaseDatabase, FirebaseDatabaseSwift
// SessionHistoryViewModel.swift
// SessionHistoryViewModel.swift
//
//  SessionHistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//


import Foundation
import SwiftUI
import FirebaseDatabase

@MainActor
class SessionHistoryViewModel: ObservableObject {
    @Published var datedSessionGroups: [DatedSessionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Add this flag for preview mode
    var isPreviewMode: Bool = false
    
    private var authViewModel: AuthViewModel
    private var ref: DatabaseReference

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.ref = Database.database().reference()
    }

    // Helper to get active User ID (for live app and previews)
    private func getActiveUserID() -> String? {
        if let firebaseUser = authViewModel.user, !firebaseUser.uid.isEmpty {
            return firebaseUser.uid
        }
        if !authViewModel.myUser.uid.isEmpty { // Fallback for previews
            return authViewModel.myUser.uid
        }
        return nil
    }

    func fetchSessionHistory() {
        // Skip fetching if in preview mode
        if isPreviewMode {
            print("SessionHistoryViewModel: Skipping fetch in preview mode")
            return
        }
        
        guard authViewModel.isSigneIn, let userID = getActiveUserID() else {
            DispatchQueue.main.async {
                if !self.authViewModel.isSigneIn {
                    self.errorMessage = "User not signed in."
                } else {
                    self.errorMessage = "User ID not available. Please try logging in again."
                }
                print("SessionHistoryViewModel: Cannot fetch history. Signed in: \(self.authViewModel.isSigneIn), UserID from helper: \(self.getActiveUserID() ?? "nil")")
                self.datedSessionGroups = []
                self.isLoading = false
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        print("🔍 Fetching session history for user: \(userID)")

        ref.child("users").child(userID).child("breathingSessions")
          .observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                print("📊 Firebase snapshot exists: \(snapshot.exists())")
                print("📊 Firebase snapshot value: \(snapshot.value ?? "nil")")
                
                guard snapshot.exists() else {
                    print("No session history found for user \(userID)")
                    self.datedSessionGroups = []
                    return
                }
                
                guard let sessionData = snapshot.value as? [String: [String: Any]] else {
                    print("❌ Error: Session data is not in expected format")
                    print("Received data type: \(type(of: snapshot.value))")
                    self.errorMessage = "Unable to load session data format."
                    return
                }
                
                print("📊 Found \(sessionData.count) sessions in Firebase")
                
                var fetchedSessions: [BreathingSession] = []
                
                for (sessionId, sessionDict) in sessionData {
                    if let session = self.parseSessionData(sessionId: sessionId, data: sessionDict) {
                        fetchedSessions.append(session)
                        print("✅ Successfully parsed session: \(session.id)")
                    } else {
                        print("❌ Failed to parse session: \(sessionId)")
                    }
                }
                
                print("📊 Successfully loaded \(fetchedSessions.count) sessions")
                self.groupSessionsByDate(sessions: fetchedSessions)
            }
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Error fetching session history: \(error.localizedDescription)"
                print("❌ Error fetching session history: \(error.localizedDescription)")
            }
        }
    }
    
    // Parse session data from Firebase format
    private func parseSessionData(sessionId: String, data: [String: Any]) -> BreathingSession? {
        print("🔄 Parsing session data: \(data)")
        
        guard let userID = data["userID"] as? String,
              let duration = data["duration"] as? TimeInterval else {
            print("❌ Missing required fields in session \(sessionId)")
            print("Available keys: \(data.keys)")
            return nil
        }
        
        // Parse session date from timestamp
        let sessionDate: Date
        if let timestamp = data["sessionDate"] as? TimeInterval {
            sessionDate = Date(timeIntervalSince1970: timestamp)
            print("✅ Parsed timestamp: \(timestamp) -> \(sessionDate)")
        } else {
            print("❌ Could not parse sessionDate from: \(data["sessionDate"] ?? "nil")")
            sessionDate = Date() // Fallback
        }
        
        // Use provided ID or fallback to sessionId
        let id = data["id"] as? String ?? sessionId
        
        return BreathingSession(
            id: id,
            userID: userID,
            sessionDate: sessionDate,
            duration: duration
        )
    }
    
    private func groupSessionsByDate(sessions: [BreathingSession]) {
        let groupedByDay = Dictionary(grouping: sessions) { session -> Date in
            Calendar.current.startOfDay(for: session.sessionDate)
        }

        self.datedSessionGroups = groupedByDay.map { (date, sessionsOnDate) -> DatedSessionGroup in
            let sortedSessionsOnDate = sessionsOnDate.sorted(by: { $0.sessionDate > $1.sessionDate })
            return DatedSessionGroup(id: date, sessions: sortedSessionsOnDate)
        }.sorted(by: { $0.id > $1.id })
        
        print("📊 Grouped \(sessions.count) sessions into \(datedSessionGroups.count) date groups")
    }
    
    // Helper method to refresh data
    func refreshData() {
        fetchSessionHistory()
    }
    
    // Helper method to clear cache and reload
    func clearAndReload() {
        datedSessionGroups = []
        errorMessage = nil
        fetchSessionHistory()
    }
}
