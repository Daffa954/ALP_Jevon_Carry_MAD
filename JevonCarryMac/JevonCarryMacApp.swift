////
////  JevonCarryMacApp.swift
////  JevonCarryMac
////
////  Created by Daffa Khoirul on 29/05/25.
////
//
import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct JevonCarryMacApp: App {
    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var quizViewModel = QuizViewModel(type: "PHQ-9")
    @StateObject private var listJournalViewModel = ListJournalViewModel()

    // Friend's original ViewModels
    @StateObject private var journalViewModel = JournalViewModel()

    // Your view models that can be initialized directly
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()

    // These depend on other view models, so we'll initialize them lazily
    @StateObject private var breathingViewModel: BreathingViewModel
    @StateObject private var sessionHistoryViewModel: SessionHistoryViewModel

    init() {
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif

        // Create temporary instances for initialization (matching your actual AuthViewModel init)
        let tempAuthVM = AuthViewModel(repository: FirebaseAuthRepository())
        let tempMusicPlayerVM = MusicPlayerViewModel()
        
        // Initialize dependent view models with temporary instances
        _breathingViewModel = StateObject(wrappedValue: BreathingViewModel(musicPlayerViewModel: tempMusicPlayerVM, authViewModel: tempAuthVM))
        _sessionHistoryViewModel = StateObject(wrappedValue: SessionHistoryViewModel(authViewModel: tempAuthVM))

        print("🔥 Firebase configured at: \(Date())")
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
                .environmentObject(journalViewModel)
                .environmentObject(listJournalViewModel)
                .environmentObject(musicPlayerViewModel)
                .environmentObject(breathingViewModel)
                .environmentObject(sessionHistoryViewModel)
                .environmentObject(historyViewModel)
                .environmentObject(quizViewModel)
        }
    }
}
