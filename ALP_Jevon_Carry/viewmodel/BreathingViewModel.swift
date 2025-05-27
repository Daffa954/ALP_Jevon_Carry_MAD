//
//  BreathingViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// BreathingViewModel.swift (Create this new file)
// Make sure to import Foundation, SwiftUI, Combine, FirebaseDatabase, FirebaseDatabaseSwift
// BreathingViewModel.swift
import Foundation
import SwiftUI
import Combine
import FirebaseDatabase


@MainActor
class BreathingViewModel: ObservableObject {
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var instructionText: String = "Select a song or tap Start"
    @Published var circleScale: CGFloat = 0.5
    @Published var circleColor: Color = AppColors.neutralColor
    @Published var isSessionActive: Bool = false
    @Published var sessionTimeElapsed: TimeInterval = 0
    @Published var selectedSong: String = "No Music"

    let availableSongs = ["No Music", "song1", "song2"] // Ensure these mp3 files are in your project

    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    private var authViewModel: AuthViewModel

    private var breathingTimer: Timer?
    private var sessionDurationTimer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    private let inhaleDuration: TimeInterval = 4.0
    private let exhaleDuration: TimeInterval = 6.0
    private let maxCircleScale: CGFloat = 1.0
    private let minCircleScale: CGFloat = 0.5

    init(musicPlayerViewModel: MusicPlayerViewModel, authViewModel: AuthViewModel) {
        self.musicPlayerViewModel = musicPlayerViewModel
        self.authViewModel = authViewModel
        
        self.musicPlayerViewModel.didSongFinishPlaying
            .sink { [weak self] in
                self?.handleSongFinished()
            }
            .store(in: &cancellables)
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

    func toggleSession() {
        if isSessionActive {
            stopSession()
        } else {
            startSession()
        }
    }

    private func startSession() {
        guard authViewModel.isSigneIn, let _ = getActiveUserID() else {
            instructionText = "Please sign in to start a session."
            print("BreathingViewModel: User not signed in or no UserID available.")
            return
        }

        isSessionActive = true
        sessionStartTime = Date()
        sessionTimeElapsed = 0
        startSessionDurationTimer()

        if selectedSong != "No Music" {
            musicPlayerViewModel.loadSong(fileName: selectedSong, autoPlay: true)
        }
        
        // Start breathing cycle regardless of music, music is auxiliary
        startBreathingCycle()
        instructionText = "Session Started..."
    }

    private func stopSession() {
        isSessionActive = false
        stopBreathingCycle()
        stopSessionDurationTimer()
        musicPlayerViewModel.stop()
        saveSessionToFirebase()

        breathingPhase = .idle
        instructionText = "Session Ended. Tap Start."
        circleScale = minCircleScale
        circleColor = AppColors.neutralColor
    }
    
    private func handleSongFinished() {
        if isSessionActive && selectedSong != "No Music" {
            print("Song finished, stopping breathing session.")
            stopSession()
        }
    }
    
    func songSelectionChanged(newSong: String) {
        self.selectedSong = newSong
        if newSong != "No Music" {
            musicPlayerViewModel.loadSong(fileName: newSong, autoPlay: false)
            instructionText = "Tap Start to begin with \(newSong)"
        } else {
            musicPlayerViewModel.stop()
            instructionText = "Tap Start for a silent session"
        }
    }

    private func startBreathingCycle() {
        breathingTimer?.invalidate()
        performInhale()
    }

    private func stopBreathingCycle() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }

    private func performInhale() {
        breathingPhase = .inhale
        instructionText = "Inhale"
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            circleScale = maxCircleScale
            circleColor = AppColors.inhaleColor
        }
        breathingTimer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { [weak self] _ in
            self?.performExhale()
        }
    }

    private func performExhale() {
        breathingPhase = .exhale
        instructionText = "Exhale"
        withAnimation(.easeInOut(duration: exhaleDuration)) {
            circleScale = minCircleScale
            circleColor = AppColors.exhaleColor
        }
        breathingTimer = Timer.scheduledTimer(withTimeInterval: exhaleDuration, repeats: false) { [weak self] _ in
            if self?.isSessionActive == true {
                self?.performInhale()
            }
        }
    }

    private func startSessionDurationTimer() {
        sessionDurationTimer?.invalidate()
        sessionDurationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isSessionActive else { return }
            self.sessionTimeElapsed += 1.0
        }
    }

    private func stopSessionDurationTimer() {
        sessionDurationTimer?.invalidate()
        sessionDurationTimer = nil
    }

    private func saveSessionToFirebase() {
        guard let userID = getActiveUserID(), let startTime = sessionStartTime else {
            print("Error saving session: UserID or start time not available. Signed in: \(authViewModel.isSigneIn)")
            return
        }
        let session = BreathingSession(userID: userID, sessionDate: startTime, duration: sessionTimeElapsed)
        let db = Database.database().reference()
        do {
            try db.child("users").child(userID).child("breathingSessions").child(session.id).setValue(from: session)
            print("Breathing session saved successfully. Duration: \(session.duration)s")
        } catch {
            print("Error saving breathing session to Firebase: \(error.localizedDescription)")
        }
    }

    enum BreathingPhase {
        case idle, inhale, exhale
    }
}
