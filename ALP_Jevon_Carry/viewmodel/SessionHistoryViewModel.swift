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

// SessionHistoryViewModel.swift
// SessionHistoryViewModel.swift

// SessionHistoryViewModel.swift
import Foundation
import SwiftUI
import FirebaseDatabase
import Combine

// MARK: - Display Data Structs & View State Enum
// (These should be defined as they were in your original/previous correct version,
// ensure they are accessible by this ViewModel)
struct BreathingSessionDisplayData: Identifiable {
    let id: String
    let originalSession: BreathingSession // Assuming BreathingSession is your model struct
    let timeText: String
    let durationText: String
}

struct DatedSessionGroupDisplayData: Identifiable {
    let id: Date // Using the date as ID for the group
    let formattedDateTitle: String
    let sessions: [BreathingSessionDisplayData]
    let sessionCountText: String
}

enum HistoryViewState {
    case loading
    case error(message: String)
    case empty
    case loaded(groups: [DatedSessionGroupDisplayData])

    // For easier comparison in previews or debugging
    var description: String {
        switch self {
        case .loading: return "loading"
        case .error(let message): return "error(\(message))"
        case .empty: return "empty"
        case .loaded(let groups): return "loaded(groups: \(groups.count))"
        }
    }
}

// Assuming BreathingSession and DatedSessionGroup (internal model for grouping) are defined elsewhere
// struct BreathingSession: Identifiable { ... }
// struct DatedSessionGroup: Identifiable { ... }


@MainActor
class SessionHistoryViewModel: ObservableObject {
    @Published var viewState: HistoryViewState
    var isPreviewMode: Bool = false // Manually set for previews if needed, or auto-detect

    // Exposed for potential onAppear check in View, or internal status.
    // Consider if direct exposure is ideal or if a status property is better.
    var firebaseListenerHandle: DatabaseHandle?
    
    private var authViewModel: AuthViewModel // Assuming AuthViewModel is your existing class
    private var ref: DatabaseReference
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Date Formatters
    private let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    private let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        self.ref = Database.database().reference()

        // Auto-detect preview mode
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.isPreviewMode = true
        }

        // Determine initial viewState based on auth state
        let initialIsSignedIn = authViewModel.isSigneIn // Assuming isSigneIn is @Published
        let initialUserIDIsAvailable: Bool
        if let firebaseUID = authViewModel.user?.uid, !firebaseUID.isEmpty { // Assuming authViewModel.user is Firebase.User
            initialUserIDIsAvailable = true
        } else if !authViewModel.myUser.uid.isEmpty { // Assuming authViewModel.myUser is your custom user struct
            initialUserIDIsAvailable = true
        } else {
            initialUserIDIsAvailable = false
        }

        if initialIsSignedIn && initialUserIDIsAvailable {
            if self.isPreviewMode {
                // For previews, configureForPreview or setupPreviewData will set the state.
                self.viewState = .empty // Default for preview before specific setup
                print("SessionHistoryViewModel Init (Preview Detected): State set to .empty, expecting preview setup.")
            } else {
                self.viewState = .loading // Real mode: start with loading
                print("SessionHistoryViewModel Init: User signed in. Setting state to .loading, will setup listener.")
                setupFirebaseListener() // Setup listener immediately
            }
        } else {
            self.viewState = .error(message: "Please sign in to view history.")
            print("SessionHistoryViewModel Init: User not signed in or no UserID. Setting state to error.")
        }

        // Setup Combine sink for auth changes
        authViewModel.$isSigneIn // Assuming isSigneIn is @Published in AuthViewModel
            .dropFirst() // Ignore the initial value already handled by init logic
            .receive(on: DispatchQueue.main) // Ensure updates are on main thread
            .sink { [weak self] isSignedIn in
                guard let self = self else { return }
                print("SessionHistoryViewModel: Auth state changed via sink, isSignedIn: \(isSignedIn)")

                if self.isPreviewMode {
                    print("SessionHistoryViewModel (Preview): Auth state change ignored by listener logic.")
                    return
                }

                if isSignedIn && self.getActiveUserID() != nil {
                    print("User is now signed in (from sink), ensuring listener is active.")
                    self.setupFirebaseListener()
                } else {
                    print("User signed out (from sink), removing listener and updating view state.")
                    self.removeFirebaseListener()
                    // Only update to error if not already in an error state from listener failure perhaps
                    if !isSignedIn { // Explicitly check isSignedIn for this message
                         self.viewState = .error(message: "Please sign in to view history.")
                    }
                }
            }
            .store(in: &cancellables)
    }


    // Made public for view's onAppear check, if you decide to use that pattern.
    // Otherwise, can be private.
    func getActiveUserID() -> String? {
        if let firebaseUser = self.authViewModel.user, !firebaseUser.uid.isEmpty {
            return firebaseUser.uid
        }
        if !self.authViewModel.myUser.uid.isEmpty {
            return self.authViewModel.myUser.uid
        }
        return nil
    }

    func setupFirebaseListener() {
        if isPreviewMode {
            print("SessionHistoryViewModel: In preview mode, Firebase listener setup bypassed.")
            if case .loading = viewState { self.viewState = .empty } // Ensure loading doesn't stick in preview
            return
        }

        guard self.authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            let message = !self.authViewModel.isSigneIn ? "User not signed in." : "User ID not available."
            if case .error(let currentMessage) = viewState, currentMessage == message {
                // Avoid redundant state updates if error is already set to the same message
            } else {
                self.viewState = .error(message: message)
            }
            print("SessionHistoryViewModel: Cannot setup listener. \(message)")
            removeFirebaseListener() // Ensure any old listener is cleared
            return
        }

        removeFirebaseListener() // Remove previous listener before adding a new one
        
        // Set loading state *before* attaching the listener if not already loading due to an error.
        // If coming from an error state, user might prefer to see error until data successfully loads.
        // However, for consistency, listener setup implies an attempt to load.
        if !matchesCurrentState(.loading) {
             self.viewState = .loading
        }
        print("SessionHistoryViewModel: Setting up Firebase listener for user: \(currentUserID) at /allBreathingSessions")

        firebaseListenerHandle = ref.child("allBreathingSessions").observe(.value, with: { [weak self] snapshot in
            guard let self = self else { return }
            print("Firebase listener: Data received.")

            guard let currentUserID = self.getActiveUserID(), self.authViewModel.isSigneIn else {
                print("Firebase listener: User signed out or ID became unavailable during data processing. Aborting.")
                // Don't change state here, auth sink should handle it. Or set to specific error.
                // self.removeFirebaseListener() // The auth sink will handle this.
                return
            }
            
            guard snapshot.exists(), let allSessionsData = snapshot.value as? [String: [String: Any]] else {
                print("Firebase listener: No sessions found in /allBreathingSessions or data is nil.")
                self.viewState = .empty
                return
            }
            
            var userSessions: [BreathingSession] = [] // Assuming BreathingSession is your model
            for (sessionId, sessionDict) in allSessionsData {
                if let sessionUserID = sessionDict["userID"] as? String, sessionUserID == currentUserID {
                    // Ensure parseSessionDataModel exists and returns your BreathingSession model
                    if let session = self.parseSessionDataModel(sessionId: sessionId, data: sessionDict) {
                        userSessions.append(session)
                    }
                }
            }

            if userSessions.isEmpty {
                print("Firebase listener: No sessions found for user \(currentUserID) after filtering.")
                self.viewState = .empty
            } else {
                print("Firebase listener: Found \(userSessions.count) sessions for user \(currentUserID).")
                let groupedModelData = self.groupSessionsByDateModel(sessions: userSessions)
                let displayData = self.prepareDisplayData(from: groupedModelData)
                self.viewState = .loaded(groups: displayData)
            }
        }, withCancel: { [weak self] error in
            guard let self = self else { return }
            print("❌ Firebase listener cancelled or error for /allBreathingSessions: \(error.localizedDescription)")
            // Avoid overwriting a "signed out" error if that's the cause
            if self.authViewModel.isSigneIn {
                self.viewState = .error(message: "Failed to listen for history updates: \(error.localizedDescription)")
            }
        })
    }

    func removeFirebaseListener() {
        if let handle = firebaseListenerHandle {
            ref.child("allBreathingSessions").removeObserver(withHandle: handle)
            firebaseListenerHandle = nil // Clear the handle
            print("SessionHistoryViewModel: Firebase listener removed from /allBreathingSessions.")
        }
    }

    // This function is for manual refresh (pull-to-refresh, Try Again button)
    func fetchSessionHistory() async { // This is the existing one-time fetch
        if isPreviewMode {
            print("SessionHistoryViewModel: In preview mode, fetchSessionHistory (manual) bypassed.")
            if case .loading = viewState { self.viewState = .empty }
            return
        }

        // Set loading state for immediate user feedback on manual refresh
        if !matchesCurrentState(.loading) { // Avoid redundant state change if already loading
             self.viewState = .loading
        }

        guard self.authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            let message = !self.authViewModel.isSigneIn ? "User not signed in." : "User ID not available."
            self.viewState = .error(message: message)
            print("SessionHistoryViewModel:fetchSessionHistory (manual): Cannot fetch. \(message)")
            return
        }
        
        print("🔍 SessionHistoryViewModel:fetchSessionHistory (MANUAL): Fetching all sessions for user: \(currentUserID)")
        do {
            let snapshot = try await ref.child("allBreathingSessions").getData()
            
            guard snapshot.exists(), let allSessionsData = snapshot.value as? [String: [String: Any]] else {
                print("No sessions found in /allBreathingSessions or data is nil (manual fetch).")
                self.viewState = .empty
                return
            }
            
            var userSessions: [BreathingSession] = [] // Assuming BreathingSession is your model
            for (sessionId, sessionDict) in allSessionsData {
                if let sessionUserID = sessionDict["userID"] as? String, sessionUserID == currentUserID {
                    // Ensure parseSessionDataModel exists and returns your BreathingSession model
                    if let session = parseSessionDataModel(sessionId: sessionId, data: sessionDict) {
                        userSessions.append(session)
                    }
                }
            }

            if userSessions.isEmpty {
                print("No sessions found for user \(currentUserID) after filtering (manual fetch).")
                self.viewState = .empty
            } else {
                print("Found \(userSessions.count) sessions for user \(currentUserID) (manual fetch).")
                let groupedModelData = groupSessionsByDateModel(sessions: userSessions)
                let displayData = prepareDisplayData(from: groupedModelData)
                self.viewState = .loaded(groups: displayData)
            }
        } catch {
            self.viewState = .error(message: "Failed to fetch history: \(error.localizedDescription)")
            print("❌ Error fetching from /allBreathingSessions (manual fetch): \(error)")
        }
    }
    
    private func matchesCurrentState(_ stateToMatch: HistoryViewState) -> Bool {
        switch (viewState, stateToMatch) {
        case (.loading, .loading): return true
        case (.empty, .empty): return true
        case (.error(let msg1), .error(let msg2)): return msg1 == msg2
        case (.loaded(let g1), .loaded(let g2)): return g1.map { $0.id } == g2.map { $0.id } // Simplified comparison
        default: return false
        }
    }

    // MARK: - Data Parsing and Formatting Logic (from your provided code)
    // Ensure these methods use your actual `BreathingSession` model
    private func parseSessionDataModel(sessionId: String, data: [String: Any]) -> BreathingSession? {
        guard let userID = data["userID"] as? String,
              let duration = data["duration"] as? TimeInterval else {
            print("❌ Parsing error: Missing userID or duration for session \(sessionId). Data: \(data)")
            return nil
        }
        let sessionDate: Date
        if let timestamp = data["sessionDate"] as? TimeInterval { // Assuming stored as timestamp
            sessionDate = Date(timeIntervalSince1970: timestamp)
        } else if let dateString = data["sessionDate"] as? String { // Example: if stored as ISO8601 string
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: dateString) {
                sessionDate = date
            } else {
                 print("❌ Parsing error: Invalid date string for sessionDate \(sessionId). Data: \(data)")
                sessionDate = Date() // Fallback, consider if this is appropriate
            }
        }
        else {
            print("❌ Parsing error: Missing or invalid sessionDate for session \(sessionId). Data: \(data)")
            sessionDate = Date() // Fallback or handle as more critical error
        }
        let id = data["id"] as? String ?? sessionId // Use outer key as fallback ID
        // Replace with your actual BreathingSession initializer
        return BreathingSession(id: id, userID: userID, sessionDate: sessionDate, duration: duration)
    }

    // Assuming DatedSessionGroup is your internal model struct for grouping
    // struct DatedSessionGroup: Identifiable { let id: Date, let sessions: [BreathingSession] }
    private func groupSessionsByDateModel(sessions: [BreathingSession]) -> [DatedSessionGroup] {
        let groupedByDay = Dictionary(grouping: sessions) { session -> Date in
            Calendar.current.startOfDay(for: session.sessionDate)
        }
        return groupedByDay.map { date, sessionsOnDate -> DatedSessionGroup in
            DatedSessionGroup(id: date, sessions: sessionsOnDate.sorted(by: { $0.sessionDate > $1.sessionDate }))
        }.sorted(by: { $0.id > $1.id }) // Most recent groups first
    }

    private func formatSectionDateTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        // Example: Check if the date is within the current week (excluding today/yesterday)
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return dayOfWeekFormatter.string(from: date) // "Monday", "Tuesday", etc.
        }
        return sectionDateFormatter.string(from: date) // Full date for older sessions
    }

    private func formatSessionDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 && seconds > 0 { return "\(minutes)m \(seconds)s" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(seconds)s"
    }

    private func prepareDisplayData(from modelGroups: [DatedSessionGroup]) -> [DatedSessionGroupDisplayData] {
        modelGroups.map { group -> DatedSessionGroupDisplayData in
            let displaySessions = group.sessions.map { session -> BreathingSessionDisplayData in
                BreathingSessionDisplayData(
                    id: session.id,
                    originalSession: session,
                    timeText: timeFormatter.string(from: session.sessionDate),
                    durationText: formatSessionDuration(session.duration)
                )
            }
            return DatedSessionGroupDisplayData(
                id: group.id,
                formattedDateTitle: formatSectionDateTitle(group.id),
                sessions: displaySessions,
                sessionCountText: "\(group.sessions.count) session\(group.sessions.count == 1 ? "" : "s")"
            )
        }
    }

    // MARK: - Preview Helper Methods (from your provided code)
    func configureForPreview(state: HistoryViewState) {
        self.isPreviewMode = true // Ensure preview mode is set
        self.viewState = state
    }

    func setupPreviewData(sampleSessions: [BreathingSession] = []) { // Assuming BreathingSession is your model
        self.isPreviewMode = true // Ensure preview mode is set
        if sampleSessions.isEmpty {
            self.viewState = .empty
            return
        }
        let modelGroups = self.groupSessionsByDateModel(sessions: sampleSessions)
        let displayGroups = self.prepareDisplayData(from: modelGroups)
        self.viewState = .loaded(groups: displayGroups)
    }
}
