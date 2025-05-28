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
// No need for FirebaseDatabaseSwift if you're doing manual JSON conversion

@MainActor
class BreathingViewModel: ObservableObject {
    // ... (all your existing properties are fine) ...
    @Published var breathingPhase: BreathingPhase = .idle
    @Published var instructionText: String = "Choose your music and begin your journey"
    @Published var circleScale: CGFloat = 0.6
    @Published var circleColor: Color = AppColors.neutralColor // Ensure AppColors is defined
    @Published var isSessionActive: Bool = false
    @Published var sessionTimeElapsed: TimeInterval = 0
    @Published var selectedSong: String = "No Music"
    
    @Published var circleOpacity: Double = 0.8
    @Published var pulseEffect: Bool = false
    @Published var breathingRate: Double = 1.0
    
    @Published var isSaving: Bool = false
    @Published var saveError: String?
    
    let availableSongs = ["No Music", "song1", "song2"]

    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    private var authViewModel: AuthViewModel
    private var ref: DatabaseReference

    private var breathingTimer: Timer?
    private var sessionDurationTimer: Timer?
    private var sessionStartTime: Date?
    private var cancellables = Set<AnyCancellable>()

    private let inhaleDuration: TimeInterval = 4.0
    private let exhaleDuration: TimeInterval = 6.0
    private let holdDuration: TimeInterval = 1.0
    private let maxCircleScale: CGFloat = 1.2
    private let minCircleScale: CGFloat = 0.6

    init(musicPlayerViewModel: MusicPlayerViewModel, authViewModel: AuthViewModel) {
        self.musicPlayerViewModel = musicPlayerViewModel
        self.authViewModel = authViewModel
        self.ref = Database.database().reference()
        
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
            pulseEffect = true
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
        
        if wasActive && sessionTimeElapsed >= 5.0 {
            saveSessionToFirebase(userID: authViewModel.user?.uid ?? "")
        } else if wasActive {
            print("Session was too short to save (duration: \(sessionTimeElapsed)s).")
            instructionText = "Session too short to be recorded."
        }

        withAnimation(.easeOut(duration: 1.0)) {
            breathingPhase = .idle
            circleScale = minCircleScale
            circleColor = AppColors.neutralColor
            circleOpacity = 0.8
            pulseEffect = false
        }
        
        if wasActive && sessionTimeElapsed >= 5.0 {
            let sessionMinutes = Int(sessionTimeElapsed / 60)
            instructionText = sessionMinutes > 0 ?
                "Beautiful session! You practiced for \(sessionMinutes) minute\(sessionMinutes == 1 ? "" : "s")" :
                "Session complete. Take a moment to appreciate your practice"
        } else if !wasActive {
            instructionText = "Choose your music and begin your journey"
        }
    }
    
    private func handleSongFinished() {
        if isSessionActive && selectedSong != "No Music" {
            print("Song finished, completing breathing session gracefully.")
            stopSession()
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
            circleColor = AppColors.inhaleColor
            circleOpacity = 1.0
        }
        
        breathingTimer = Timer.scheduledTimer(withTimeInterval: inhaleDuration, repeats: false) { [weak self] _ in
            self?.performHold()
        }
    }
    
    private func performHold() {
        breathingPhase = .hold
        instructionText = "Hold..."
        
        withAnimation(.easeInOut(duration: holdDuration)) {
            circleOpacity = 0.9
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
            circleColor = AppColors.exhaleColor
            circleOpacity = 0.7
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
    
    func updateAuthViewModel(_ newAuthViewModel: AuthViewModel) {
        self.authViewModel = newAuthViewModel
        print("AuthViewModel updated. New Auth signed in: \(self.authViewModel.isSigneIn), UserID from helper: \(self.getActiveUserID() ?? "nil")")
    }

    // MARK: - Firebase Operations (Using Manual JSON-like Dictionary)
    
    private func saveSessionToFirebase(userID : String) {
        print("--- Attempting to save session to Firebase (Manual JSON) ---")
        print("Current AuthViewModel.isSigneIn: \(authViewModel.isSigneIn)")

        guard let userID = getActiveUserID() else {
            print("❌ Error saving session: UserID not available. Check auth state. getActiveUserID() returned nil.")
            DispatchQueue.main.async {
                self.saveError = "Unable to save session: User not identified. Please sign in again."
                self.isSaving = false
            }
            return
        }

        guard let startTime = sessionStartTime else {
            print("❌ Error saving session: Session start time is nil.")
            DispatchQueue.main.async {
                self.saveError = "Unable to save session: Critical session data missing (start time)."
                self.isSaving = false
            }
            return
        }

        guard sessionTimeElapsed >= 5 else {
            print("ℹ️ Session too short to save (duration: \(sessionTimeElapsed)s). Not saving.")
            return
        }

        print("Preparing to save session for UserID: \(userID) | StartTime: \(startTime) | Duration: \(sessionTimeElapsed)")

        DispatchQueue.main.async {
            self.isSaving = true
            self.saveError = nil
        }

        let session = BreathingSession(userID: userID, sessionDate: startTime, duration: sessionTimeElapsed)
        
        // 1. Create the [String: Any] dictionary manually
        // This is similar to what JSONEncoder would produce for simple types.
        let sessionData: [String: Any] = [
            "id": session.id,
            "userID": userID,
            "sessionDate": session.sessionDate.timeIntervalSince1970, // Store as UNIX timestamp (Double)
            "duration": session.duration // TimeInterval (Double)
        ]
        
        // Alternative using JSONEncoder and JSONSerialization (like JournalViewModel)
        // This is more robust if your model becomes complex, but manual is fine for this simple model.
        /*
        guard let jsonData = try? JSONEncoder().encode(session),
              let sessionData = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
            print("❌ Error saving session: Failed to encode session to JSON dictionary.")
            DispatchQueue.main.async {
                self.saveError = "Failed to prepare session data for saving."
                self.isSaving = false
            }
            return
        }
        */
        
        let sessionNodeRef = ref.child("users").child(userID).child("breathingSessions").child(session.id)
        
        print("Attempting to save session dictionary: \(sessionData) to path: \(sessionNodeRef.url)")

        sessionNodeRef.setValue(sessionData) { [weak self] error, databaseRef in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.saveError = "Failed to save session: \(error.localizedDescription)"
                    print("❌ Firebase save error (manual JSON): \(error.localizedDescription)")
                    print("Error details: \(error)") // CRITICAL
                } else {
                    print("✅ Successfully saved breathing session (manual JSON) with ID: \(session.id) to path: \(databaseRef.url)")
                    self.saveError = nil
                }
            }
        }
    }
    
    func retrySaveSession() {
        guard getActiveUserID() != nil, sessionStartTime != nil, sessionTimeElapsed >= 5 else {
            print("Cannot retry save: Missing necessary data or session too short.")
            saveError = "Cannot retry: Missing data."
            return
        }
        print("Retrying to save session...")
        saveSessionToFirebase(userID: authViewModel.user?.uid ?? "")
    }

    enum BreathingPhase {
        case idle, inhale, hold, exhale
    }
}

