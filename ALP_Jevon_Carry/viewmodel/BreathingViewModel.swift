//
//  BreathingViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import Foundation
import SwiftUI
import Combine

// Breathing phases for the session
enum BreathingPhase {
    case idle, inhale, hold, exhale
}

// Main ViewModel for breathing sessions - simplified and efficient
@MainActor
class BreathingViewModel: ObservableObject {
    // Published properties for UI state
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var instructionText: String = "Choose your music and begin your journey"
    @Published var circleScale: CGFloat = 0.6
    @Published var circleColor: Color = Color.gray
    @Published var isSessionActive: Bool = false
    @Published var sessionTimeElapsed: TimeInterval = 0
    @Published var selectedSong: String = "No Music"
    @Published var circleOpacity: Double = 0.8
    @Published var pulseEffect: Bool = false
    @Published var breathingRate: Double = 1.0
    @Published var isSaving: Bool = false
    @Published var saveError: String?
    
    // Available songs array
    let availableSongs = ["No Music", "song1", "song2"]

    // View models and repositories
    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    private var authViewModel: AuthViewModel
    private let breathingRepo: FirebaseBreathingRepository

    // Timers and session data
    private var breathingTimer: Timer?
    private var sessionDurationTimer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // Color constants
    private let neutralColorPlaceholder: Color = Color.gray
    private let inhaleColorPlaceholder: Color = Color.blue.opacity(0.7)
    private let exhaleColorPlaceholder: Color = Color.orange

    // Timing constants
    private let inhaleDuration: TimeInterval = 4.0
    private let exhaleDuration: TimeInterval = 6.0
    private let holdDuration: TimeInterval = 1.0
    private let maxCircleScale: CGFloat = 1.2
    private let minCircleScale: CGFloat = 0.6

    // Initialize the ViewModel
    init(musicPlayerViewModel: MusicPlayerViewModel, authViewModel: AuthViewModel, breathingRepo: FirebaseBreathingRepository = FirebaseBreathingRepository()) {
        self.musicPlayerViewModel = musicPlayerViewModel
        self.authViewModel = authViewModel
        self.breathingRepo = breathingRepo

        // Set initial circle color
        self.circleColor = neutralColorPlaceholder

        // Listen for song finish events
        self.musicPlayerViewModel.didSongFinishPlaying
            .sink { [weak self] in
                self?.handleSongFinished()
            }
            .store(in: &cancellables)
    }

    // Get the active user ID from authentication
    private func getActiveUserID() -> String? {
        if let firebaseUser = authViewModel.user, !firebaseUser.uid.isEmpty {
            return firebaseUser.uid
        }
        if !authViewModel.myUser.uid.isEmpty {
            return authViewModel.myUser.uid
        }
        return nil
    }

    // Toggle session start/stop
    func toggleSession() {
        if isSessionActive {
            stopSession()
        } else {
            startSession()
        }
    }

    // Start a breathing session
    private func startSession() {
        guard authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            instructionText = "Please sign in to start your mindful journey"
            return
        }
        
        // Set session state
        isSessionActive = true
        sessionStartTime = Date()
        sessionTimeElapsed = 0
        saveError = nil
        
        // Start timers
        startSessionDurationTimer()

        // Play music if selected
        if selectedSong != "No Music" {
            musicPlayerViewModel.loadSong(fileName: selectedSong, autoPlay: true)
        }

        // Start visual effects
        withAnimation(.easeInOut(duration: 0.8)) {
            pulseEffect = true
        }
        
        // Start breathing cycle
        startBreathingCycle()
        instructionText = "Find your center and breathe deeply..."
    }

    // Stop the breathing session
    private func stopSession() {
        let wasActive = isSessionActive
        isSessionActive = false
        
        // Stop all timers and cycles
        stopBreathingCycle()
        stopSessionDurationTimer()
        musicPlayerViewModel.stop()

        // Save session if it was long enough
        if wasActive && sessionTimeElapsed >= 5.0 {
            saveSessionToFirebase()
        } else if wasActive {
            instructionText = "Session too short to be recorded."
        }

        // Reset visual state
        withAnimation(.easeOut(duration: 1.0)) {
            breathingPhase = .idle
            circleScale = minCircleScale
            circleColor = neutralColorPlaceholder
            circleOpacity = 0.8
            pulseEffect = false
        }

        // Set completion message
        if wasActive && sessionTimeElapsed >= 5.0 {
            let sessionMinutes = Int(sessionTimeElapsed / 60)
            instructionText = sessionMinutes > 0 ?
                "Beautiful session! You practiced for \(sessionMinutes) minute\(sessionMinutes == 1 ? "" : "s")" :
                "Session complete. Take a moment to appreciate your practice"
        } else if !wasActive {
            instructionText = "Choose your music and begin your journey"
        }
    }

    // Handle when song finishes playing
    private func handleSongFinished() {
        if isSessionActive && selectedSong != "No Music" {
            stopSession()
        }
    }

    // Handle song selection changes
    func songSelectionChanged(newSong: String) {
        self.selectedSong = newSong

        withAnimation(.easeInOut(duration: 0.3)) {
            if newSong != "No Music" {
                musicPlayerViewModel.loadSong(fileName: newSong, autoPlay: false)
                instructionText = "Ready to breathe with \(newSong.capitalized)"
            } else {
                musicPlayerViewModel.stop()
                instructionText = "Ready for a peaceful silent session"
            }
        }
    }

    // Start the breathing cycle
    private func startBreathingCycle() {
        breathingTimer?.invalidate()
        performInhale()
    }

    // Stop the breathing cycle
    private func stopBreathingCycle() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }

    // Perform inhale phase
    private func performInhale() {
        breathingPhase = .inhale
        instructionText = "Breathe in... fill your lungs"

        withAnimation(.easeInOut(duration: inhaleDuration)) {
            circleScale = maxCircleScale
            circleColor = inhaleColorPlaceholder
            circleOpacity = 1.0
        }

        breathingTimer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { [weak self] _ in
            self?.performHold()
        }
    }

    // Perform hold phase
    private func performHold() {
        if holdDuration <= 0 {
            performExhale()
            return
        }
        
        breathingPhase = .hold
        instructionText = "Hold..."

        withAnimation(.easeInOut(duration: holdDuration)) {
            circleOpacity = 0.9
        }

        breathingTimer = Timer.scheduledTimer(withTimeInterval: holdDuration, repeats: false) { [weak self] _ in
            self?.performExhale()
        }
    }

    // Perform exhale phase
    private func performExhale() {
        breathingPhase = .exhale
        instructionText = "Breathe out... release and relax"

        withAnimation(.easeInOut(duration: exhaleDuration)) {
            circleScale = minCircleScale
            circleColor = exhaleColorPlaceholder
            circleOpacity = 0.7
        }

        breathingTimer = Timer.scheduledTimer(withTimeInterval: exhaleDuration, repeats: false) { [weak self] _ in
            if self?.isSessionActive == true {
                self?.performInhale()
            }
        }
    }

    // Start session duration timer
    private func startSessionDurationTimer() {
        sessionDurationTimer?.invalidate()
        sessionDurationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isSessionActive else { return }
            self.sessionTimeElapsed += 1.0
        }
    }

    // Stop session duration timer
    private func stopSessionDurationTimer() {
        sessionDurationTimer?.invalidate()
        sessionDurationTimer = nil
    }

    // Update authentication view model
    func updateAuthViewModel(_ newAuthViewModel: AuthViewModel) {
        self.authViewModel = newAuthViewModel
    }

    // Save session to Firebase
    private func saveSessionToFirebase() {
        guard let userID = getActiveUserID() else {
            self.saveError = "Unable to save session: User not identified. Please sign in again."
            self.isSaving = false
            return
        }

        guard let startTime = sessionStartTime else {
            self.saveError = "Unable to save session: Critical session data missing (start time)."
            self.isSaving = false
            return
        }

        guard sessionTimeElapsed >= 5 else {
            return
        }

        self.isSaving = true
        self.saveError = nil

        let session = BreathingSession(userID: userID, sessionDate: startTime, duration: sessionTimeElapsed)
        breathingRepo.addSession(session) { [weak self] success in
            guard let self = self else { return }
            self.isSaving = false
            if !success {
                self.saveError = "Failed to save session."
            } else {
                self.saveError = nil
            }
        }
    }

    // Retry saving session
    func retrySaveSession() {
        guard getActiveUserID() != nil, sessionStartTime != nil, sessionTimeElapsed >= 5 else {
            saveError = "Cannot retry: Missing data."
            return
        }
        saveSessionToFirebase()
    }
}
