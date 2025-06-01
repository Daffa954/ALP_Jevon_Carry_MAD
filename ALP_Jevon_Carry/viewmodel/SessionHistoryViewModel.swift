//
//  SessionHistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 01/06/25.
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

//
//  SessionHistoryViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import Foundation
import SwiftUI
import Combine

// Main ViewModel for session history - simplified and efficient
@MainActor
class SessionHistoryViewModel: ObservableObject {
    // Published properties for UI state
    @Published var isLoading = false
    @Published var isEmpty = true
    @Published var groupedSessions: [DatedSessionGroup] = []
    
    // Internal properties
    var isPreviewMode: Bool = false
    private var authViewModel: AuthViewModel
    private let sessionRepo: FirebaseSessionHistoryRepository
    private var cancellables = Set<AnyCancellable>()
    var isListening = false

    // Date formatters
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

    // Initialize the ViewModel
    init(authViewModel: AuthViewModel, sessionRepo: FirebaseSessionHistoryRepository = FirebaseSessionHistoryRepository()) {
        self.authViewModel = authViewModel
        self.sessionRepo = sessionRepo

        // Check if running in preview mode
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.isPreviewMode = true
        }

        // Set initial state based on authentication
        let initialIsSignedIn = authViewModel.isSigneIn
        let initialUserIDIsAvailable = getActiveUserID() != nil

        if initialIsSignedIn && initialUserIDIsAvailable {
            if !self.isPreviewMode {
                fetchSessionHistory()
            }
        }

        // Listen for authentication changes
        authViewModel.$isSigneIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn in
                guard let self = self else { return }
                if self.isPreviewMode { return }
                if isSignedIn && self.getActiveUserID() != nil {
                    self.fetchSessionHistory()
                } else {
                    self.groupedSessions = []
                    self.isEmpty = true
                }
            }
            .store(in: &cancellables)
    }

    // Get the active user ID from authentication
    func getActiveUserID() -> String? {
        if let firebaseUser = self.authViewModel.user, !firebaseUser.uid.isEmpty {
            return firebaseUser.uid
        }
        if !self.authViewModel.myUser.uid.isEmpty {
            return self.authViewModel.myUser.uid
        }
        return nil
    }

    // Fetch session history from Firebase
    func fetchSessionHistory() {
        guard self.authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            self.groupedSessions = []
            self.isEmpty = true
            return
        }
        
        self.isLoading = true
        sessionRepo.fetchAllSessions(for: currentUserID) { [weak self] sessions in
            guard let self = self else { return }
            self.isLoading = false
            
            if sessions.isEmpty {
                self.isEmpty = true
                self.groupedSessions = []
            } else {
                self.isEmpty = false
                self.groupedSessions = self.groupSessionsByDate(sessions: sessions)
            }
        }
    }

    // Group sessions by date and sort them
    private func groupSessionsByDate(sessions: [BreathingSession]) -> [DatedSessionGroup] {
        let groupedByDay = Dictionary(grouping: sessions) { session -> Date in
            Calendar.current.startOfDay(for: session.sessionDate)
        }
        
        return groupedByDay.map { date, sessionsOnDate -> DatedSessionGroup in
            DatedSessionGroup(id: date, sessions: sessionsOnDate.sorted(by: { $0.sessionDate > $1.sessionDate }))
        }.sorted(by: { $0.id > $1.id })
    }

    // Format date title for sections
    func formatSectionDateTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return dayOfWeekFormatter.string(from: date)
        }
        return sectionDateFormatter.string(from: date)
    }

    // Format session duration
    func formatSessionDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 && seconds > 0 { return "\(minutes)m \(seconds)s" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(seconds)s"
    }

    // Format session time
    func formatSessionTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }

    // Format session count text
    func formatSessionCountText(_ count: Int) -> String {
        return "\(count) session\(count == 1 ? "" : "s")"
    }

    // Configure for preview mode
    func configureForPreview(isEmpty: Bool = false, isLoading: Bool = false) {
        self.isPreviewMode = true
        self.isEmpty = isEmpty
        self.isLoading = isLoading
        self.groupedSessions = []
    }

    // Setup preview data
    func setupPreviewData(sampleSessions: [BreathingSession] = []) {
        self.isPreviewMode = true
        if sampleSessions.isEmpty {
            self.isEmpty = true
            self.groupedSessions = []
        } else {
            self.isEmpty = false
            self.groupedSessions = self.groupSessionsByDate(sessions: sampleSessions)
        }
    }
    
    // Setup Firebase listener for real-time updates
    func setupFirebaseListener() {
        guard !isListening, let userID = getActiveUserID() else { return }
        isListening = true
        sessionRepo.startListening(for: userID) { [weak self] sessions in
            guard let self = self else { return }
            if sessions.isEmpty {
                self.isEmpty = true
                self.groupedSessions = []
            } else {
                self.isEmpty = false
                self.groupedSessions = self.groupSessionsByDate(sessions: sessions)
            }
        }
    }

    // Remove Firebase listener
    func removeFirebaseListener() {
        sessionRepo.stopListening()
        isListening = false
    }
}

