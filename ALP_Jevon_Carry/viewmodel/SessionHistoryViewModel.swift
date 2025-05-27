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
import Foundation
import SwiftUI
import FirebaseDatabase

struct DatedSessionGroup: Identifiable, Hashable {
    let id: Date // The day (normalized to midnight)
    var sessions: [BreathingSession]
}

@MainActor
class SessionHistoryViewModel: ObservableObject {
    @Published var datedSessionGroups: [DatedSessionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Add this flag for preview mode
    var isPreviewMode: Bool = false

    private var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
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
            if !authViewModel.isSigneIn {
                errorMessage = "User not signed in."
            } else { // Signed in but no ID (should be rare with the helper if myUser.uid is set in preview)
                errorMessage = "User ID not available. Please try logging in again."
            }
            print("SessionHistoryViewModel: Cannot fetch history. Signed in: \(authViewModel.isSigneIn), UserID from helper: \(getActiveUserID() ?? "nil")")
            self.datedSessionGroups = []
            self.isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil
        let db = Database.database().reference()

        db.child("users").child(userID).child("breathingSessions")
          .observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            self.isLoading = false

            guard snapshot.exists(), let children = snapshot.children.allObjects as? [DataSnapshot] else {
                print("No session history found for user \(userID) or error reading data.")
                self.datedSessionGroups = []
                return
            }

            var fetchedSessions: [BreathingSession] = []
            for child in children {
                do {
                    let session = try child.data(as: BreathingSession.self)
                    fetchedSessions.append(session)
                } catch {
                    print("Error decoding session \(child.key): \(error.localizedDescription)")
                    // self.errorMessage = "Failed to load some session data." // Be cautious with this, might overwrite other errors
                }
            }
            if fetchedSessions.isEmpty && children.count > 0 {
                 print("Warning: Had \(children.count) children snapshots but fetchedSessions is empty. Check Codable mapping.")
            }
            self.groupSessionsByDate(sessions: fetchedSessions)
        } withCancel: { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            self.errorMessage = "Error fetching session history: \(error.localizedDescription)"
            print("Error fetching session history: \(error.localizedDescription)")
        }
    }
    
    private func groupSessionsByDate(sessions: [BreathingSession]) {
        let groupedByDay = Dictionary(grouping: sessions) { session -> Date in
            Calendar.current.startOfDay(for: session.sessionDate)
        }

        self.datedSessionGroups = groupedByDay.map { (date, sessionsOnDate) -> DatedSessionGroup in
            let sortedSessionsOnDate = sessionsOnDate.sorted(by: { $0.sessionDate > $1.sessionDate })
            return DatedSessionGroup(id: date, sessions: sortedSessionsOnDate)
        }.sorted(by: { $0.id > $1.id })
    }
}
