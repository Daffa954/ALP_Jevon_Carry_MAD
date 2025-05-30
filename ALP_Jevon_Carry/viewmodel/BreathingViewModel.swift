//
//  BreathingViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// BreathingViewModel.swift (Create this new file)
// Make sure to import Foundation, SwiftUI, Combine, FirebaseDatabase, FirebaseDatabaseSwift
// BreathingViewModel.swift
//
//  BreathingViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// BreathingViewModel.swift
import Foundation
import SwiftUI
import Combine
import FirebaseDatabase

@MainActor
class BreathingViewModel: ObservableObject {
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var instructionText: String = "Choose your music and begin your journey"
    @Published var circleScale: CGFloat = 0.6
    // MODIFICATION: Changed from AppColors.neutralColor
    @Published var circleColor: Color = Color.gray // Placeholder for neutralColor
    @Published var isSessionActive: Bool = false
    @Published var sessionTimeElapsed: TimeInterval = 0
    @Published var selectedSong: String = "No Music"
    
    @Published var circleOpacity: Double = 0.8
    @Published var pulseEffect: Bool = false
    @Published var breathingRate: Double = 1.0 // This was unused, consider if needed
    
    @Published var isSaving: Bool = false
    @Published var saveError: String?
    
    let availableSongs = ["No Music", "song1", "song2"] // Example song names

    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    private var authViewModel: AuthViewModel
    private var ref: DatabaseReference

    private var breathingTimer: Timer?
    private var sessionDurationTimer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    // MODIFICATION: Direct Color definitions instead of AppColors
    private let neutralColorPlaceholder: Color = Color.gray
    private let inhaleColorPlaceholder: Color = Color.blue.opacity(0.7)
    private let exhaleColorPlaceholder: Color = Color.orange

    private let inhaleDuration: TimeInterval = 4.0
    private let exhaleDuration: TimeInterval = 6.0
    private let holdDuration: TimeInterval = 1.0 // Optional hold
    private let maxCircleScale: CGFloat = 1.2
    private let minCircleScale: CGFloat = 0.6

    init(musicPlayerViewModel: MusicPlayerViewModel, authViewModel: AuthViewModel) {
        self.musicPlayerViewModel = musicPlayerViewModel
        self.authViewModel = authViewModel
        self.ref = Database.database().reference()
        
        // Set initial circle color
        self.circleColor = neutralColorPlaceholder
        
        self.musicPlayerViewModel.didSongFinishPlaying
            .sink { [weak self] in
                self?.handleSongFinished()
            }
            .store(in: &cancellables)
        
        print("BreathingViewModel initialized. Auth signed in: \(self.authViewModel.isSigneIn), UserID from helper: \(self.getActiveUserID() ?? "nil")")
    }

    private func getActiveUserID() -> String? {
        if let firebaseUser = authViewModel.user, !firebaseUser.uid.isEmpty {
            print("getActiveUserID: Using Firebase user UID: \(firebaseUser.uid)")
            return firebaseUser.uid
        }
        // Fallback for non-Firebase Auth user or previews
        if !authViewModel.myUser.uid.isEmpty {
            print("getActiveUserID: Using myUser UID: \(authViewModel.myUser.uid)")
            return authViewModel.myUser.uid
        }
        print("⚠️ getActiveUserID: Could not retrieve a valid user ID. Firebase user: \(authViewModel.user?.uid ?? "nil"), myUser.uid: \(authViewModel.myUser.uid)")
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
        print("Attempting to start session. Auth signed in: \(authViewModel.isSigneIn)")
        guard authViewModel.isSigneIn, let currentUserID = getActiveUserID() else {
            instructionText = "Please sign in to start your mindful journey"
            print("Start session blocked: User not signed in or UserID not available. ActiveUserID: \(getActiveUserID() ?? "nil")")
            return
        }
        print("Starting session for UserID: \(currentUserID)")

        isSessionActive = true
        sessionStartTime = Date()
        sessionTimeElapsed = 0
        saveError = nil
        startSessionDurationTimer()

        if selectedSong != "No Music" {
            musicPlayerViewModel.loadSong(fileName: selectedSong, autoPlay: true)
        }
        
        withAnimation(.easeInOut(duration: 0.8)) {
            pulseEffect = true // If you have a pulse animation
        }
        
        startBreathingCycle()
        instructionText = "Find your center and breathe deeply..."
    }

    private func stopSession() {
        print("Stopping session. Session time elapsed: \(sessionTimeElapsed)")
        let wasActive = isSessionActive
        isSessionActive = false
        stopBreathingCycle()
        stopSessionDurationTimer()
        musicPlayerViewModel.stop()
        
        if wasActive && sessionTimeElapsed >= 5.0 { // Save if session was active and long enough
            saveSessionToFirebase() // MODIFICATION: No longer needs userID parameter explicitly passed
        } else if wasActive {
            print("Session was too short to save (duration: \(sessionTimeElapsed)s).")
            instructionText = "Session too short to be recorded."
        }

        withAnimation(.easeOut(duration: 1.0)) {
            breathingPhase = .idle
            circleScale = minCircleScale
            circleColor = neutralColorPlaceholder // MODIFICATION
            circleOpacity = 0.8
            pulseEffect = false
        }
        
        if wasActive && sessionTimeElapsed >= 5.0 {
            let sessionMinutes = Int(sessionTimeElapsed / 60)
            instructionText = sessionMinutes > 0 ?
                "Beautiful session! You practiced for \(sessionMinutes) minute\(sessionMinutes == 1 ? "" : "s")" :
                "Session complete. Take a moment to appreciate your practice"
        } else if !wasActive { // If session was never active (e.g. user pressed start then stop immediately)
            instructionText = "Choose your music and begin your journey"
        }
    }
    
    private func handleSongFinished() {
        if isSessionActive && selectedSong != "No Music" {
            print("Song finished, completing breathing session gracefully.")
            stopSession() // This will trigger saveSessionToFirebase if conditions are met
        }
    }
    
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

    private func startBreathingCycle() {
        breathingTimer?.invalidate()
        // Reset to neutral before starting if needed, or let performInhale handle it
        // circleColor = neutralColorPlaceholder
        performInhale()
    }

    private func stopBreathingCycle() {
        breathingTimer?.invalidate()
        breathingTimer = nil
    }

    private func performInhale() {
        breathingPhase = .inhale
        instructionText = "Breathe in... fill your lungs"
        
        withAnimation(.easeInOut(duration: inhaleDuration)) {
            circleScale = maxCircleScale
            circleColor = inhaleColorPlaceholder // MODIFICATION
            circleOpacity = 1.0
        }
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { [weak self] _ in
            self?.performHold()
        }
    }
    
    private func performHold() {
        if holdDuration <= 0 { // Skip hold if duration is zero or less
            performExhale()
            return
        }
        breathingPhase = .hold
        instructionText = "Hold..."
        
        // Color can remain inhaleColor or change to a neutral hold color
        // circleColor = neutralColorPlaceholder
        withAnimation(.easeInOut(duration: holdDuration)) {
            circleOpacity = 0.9 // Example subtle change for hold
        }
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: holdDuration, repeats: false) { [weak self] _ in
            self?.performExhale()
        }
    }

    private func performExhale() {
        breathingPhase = .exhale
        instructionText = "Breathe out... release and relax"
        
        withAnimation(.easeInOut(duration: exhaleDuration)) {
            circleScale = minCircleScale
            circleColor = exhaleColorPlaceholder // MODIFICATION
            circleOpacity = 0.7
        }
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: exhaleDuration, repeats: false) { [weak self] _ in
            if self?.isSessionActive == true {
                self?.performInhale() // Loop back to inhale
            }
        }
    }

    private func startSessionDurationTimer() {
        sessionDurationTimer?.invalidate() // Ensure no multiple timers
        sessionDurationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isSessionActive else { return }
            self.sessionTimeElapsed += 1.0
        }
    }

    private func stopSessionDurationTimer() {
        sessionDurationTimer?.invalidate()
        sessionDurationTimer = nil
    }
    
    // This function might be useful if AuthViewModel can change post-init,
    // e.g., if this ViewModel is a singleton and user logs in/out.
    // If BreathingViewModel is recreated on auth changes, this might not be needed.
    func updateAuthViewModel(_ newAuthViewModel: AuthViewModel) {
        self.authViewModel = newAuthViewModel
        print("AuthViewModel updated. New Auth signed in: \(self.authViewModel.isSigneIn), UserID from helper: \(self.getActiveUserID() ?? "nil")")
    }

    // MARK: - Firebase Operations
    
    // MODIFICATION: Removed userID parameter as it's fetched internally
    private func saveSessionToFirebase() {
        print("--- Attempting to save session to Firebase ---")
        
        guard let userID = getActiveUserID() else {
            print("❌ Error saving session: UserID not available. Check auth state.")
            self.saveError = "Unable to save session: User not identified. Please sign in again."
            self.isSaving = false
            return
        }

        guard let startTime = sessionStartTime else {
            print("❌ Error saving session: Session start time is nil.")
            self.saveError = "Unable to save session: Critical session data missing (start time)."
            self.isSaving = false
            return
        }

        guard sessionTimeElapsed >= 5 else { // Ensure session is at least 5 seconds
            print("ℹ️ Session too short to save (duration: \(sessionTimeElapsed)s). Not saving.")
            // Optionally, update instructionText here if needed, or rely on stopSession's logic
            return
        }

        print("Preparing to save session for UserID: \(userID) | StartTime: \(startTime) | Duration: \(sessionTimeElapsed)")
        self.isSaving = true
        self.saveError = nil

        let session = BreathingSession(userID: userID, sessionDate: startTime, duration: sessionTimeElapsed)
        
        let sessionData: [String: Any] = [
            "id": session.id,
            "userID": userID, // Crucial: userID is now part of the data at the top level
            "sessionDate": session.sessionDate.timeIntervalSince1970,
            "duration": session.duration
        ]
        
        // MODIFICATION: Changed Firebase path to a top-level collection
        let sessionNodeRef = ref.child("allBreathingSessions").child(session.id)
        
        print("Attempting to save session dictionary: \(sessionData) to path: \(sessionNodeRef.url)")

        sessionNodeRef.setValue(sessionData) { [weak self] error, databaseRef in
            guard let self = self else { return }
            // Ensure UI updates are on the main thread (already handled by @MainActor for properties)
            // DispatchQueue.main.async { ... } not strictly needed here for property updates
            self.isSaving = false
            if let error = error {
                self.saveError = "Failed to save session: \(error.localizedDescription)"
                print("❌ Firebase save error: \(error.localizedDescription)")
            } else {
                print("✅ Successfully saved breathing session with ID: \(session.id) to path: \(databaseRef.url)")
                self.saveError = nil
                // instructionText can be updated here or rely on stopSession
            }
        }
    }
    
    func retrySaveSession() {
        // No need to pass userID, saveSessionToFirebase will fetch it
        guard getActiveUserID() != nil, sessionStartTime != nil, sessionTimeElapsed >= 5 else {
            print("Cannot retry save: Missing necessary data or session too short.")
            saveError = "Cannot retry: Missing data."
            return
        }
        print("Retrying to save session...")
        saveSessionToFirebase() // MODIFICATION
    }

    enum BreathingPhase {
        case idle, inhale, hold, exhale
    }
}
