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
import Combine

struct BreathingSessionDisplayData: Identifiable {
    let id: String
    let originalSession: BreathingSession
    let timeText: String
    let durationText: String
}

struct DatedSessionGroupDisplayData: Identifiable {
    let id: Date
    let formattedDateTitle: String
    let sessions: [BreathingSessionDisplayData]
    let sessionCountText: String
}

enum HistoryViewState {
    case loading
    case error(message: String)
    case empty
    case loaded(groups: [DatedSessionGroupDisplayData])

    var description: String {
        switch self {
        case .loading: return "loading"
        case .error(let message): return "error(\(message))"
        case .empty: return "empty"
        case .loaded(let groups): return "loaded(groups: \(groups.count))"
        }
    }
}

@MainActor
class SessionHistoryViewModel: ObservableObject {
    @Published var viewState: HistoryViewState
    var isPreviewMode: Bool = false
    private var authViewModel: AuthViewModel
    private let sessionRepo: FirebaseSessionHistoryRepository
    private var cancellables = Set<AnyCancellable>()
    var isListening = false

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

    init(authViewModel: AuthViewModel, sessionRepo: FirebaseSessionHistoryRepository = FirebaseSessionHistoryRepository()) {
        self.authViewModel = authViewModel
        self.sessionRepo = sessionRepo

        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.isPreviewMode = true
        }

        let initialIsSignedIn = authViewModel.isSigneIn
        let initialUserIDIsAvailable: Bool
        if let firebaseUID = authViewModel.user?.uid, !firebaseUID.isEmpty {
            initialUserIDIsAvailable = true
        } else if !authViewModel.myUser.uid.isEmpty {
            initialUserIDIsAvailable = true
        } else {
            initialUserIDIsAvailable = false
        }

        if initialIsSignedIn && initialUserIDIsAvailable {
            if self.isPreviewMode {
                self.viewState = .empty
            } else {
                self.viewState = .loading
                fetchSessionHistory()
            }
        } else {
            self.viewState = .error(message: "Please sign in to view history.")
        }

        authViewModel.$isSigneIn
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSignedIn in
                guard let self = self else { return }
                if self.isPreviewMode { return }
                if isSignedIn && self.getActiveUserID() != nil {
                    self.fetchSessionHistory()
                } else {
                    self.viewState = .error(message: "Please sign in to view history.")
                }
            }
            .store(in: &cancellables)
    }

    func getActiveUserID() -> String? {
        if let firebaseUser = self.authViewModel.user, !firebaseUser.uid.isEmpty {
            return firebaseUser.uid
        }
        if !self.authViewModel.myUser.uid.isEmpty {
            return self.authViewModel.myUser.uid
        }
        return nil
    }

    func fetchSessionHistory() {
        guard self.authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            self.viewState = .error(message: "Please sign in to view history.")
            return
        }
        self.viewState = .loading
        sessionRepo.fetchAllSessions(for: currentUserID) { [weak self] sessions in
            guard let self = self else { return }
            if sessions.isEmpty {
                self.viewState = .empty
            } else {
                let groupedModelData = self.groupSessionsByDateModel(sessions: sessions)
                let displayData = self.prepareDisplayData(from: groupedModelData)
                self.viewState = .loaded(groups: displayData)
            }
        }
    }

    private func groupSessionsByDateModel(sessions: [BreathingSession]) -> [DatedSessionGroup] {
        let groupedByDay = Dictionary(grouping: sessions) { session -> Date in
            Calendar.current.startOfDay(for: session.sessionDate)
        }
        return groupedByDay.map { date, sessionsOnDate -> DatedSessionGroup in
            DatedSessionGroup(id: date, sessions: sessionsOnDate.sorted(by: { $0.sessionDate > $1.sessionDate }))
        }.sorted(by: { $0.id > $1.id })
    }

    private func formatSectionDateTitle(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            return dayOfWeekFormatter.string(from: date)
        }
        return sectionDateFormatter.string(from: date)
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

    func configureForPreview(state: HistoryViewState) {
        self.isPreviewMode = true
        self.viewState = state
    }

    func setupPreviewData(sampleSessions: [BreathingSession] = []) {
        self.isPreviewMode = true
        if sampleSessions.isEmpty {
            self.viewState = .empty
            return
        }
        let modelGroups = self.groupSessionsByDateModel(sessions: sampleSessions)
        let displayGroups = self.prepareDisplayData(from: modelGroups)
        self.viewState = .loaded(groups: displayGroups)
    }
    
    func setupFirebaseListener() {
        guard !isListening, let userID = getActiveUserID() else { return }
        isListening = true
        sessionRepo.startListening(for: userID) { [weak self] sessions in
            guard let self = self else { return }
            if sessions.isEmpty {
                self.viewState = .empty
            } else {
                let groupedModelData = self.groupSessionsByDateModel(sessions: sessions)
                let displayData = self.prepareDisplayData(from: groupedModelData)
                self.viewState = .loaded(groups: displayData)
            }
        }
    }

    func removeFirebaseListener() {
        sessionRepo.stopListening()
        isListening = false
    }
}



