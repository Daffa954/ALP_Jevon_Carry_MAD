//
//  ALP_Jevon_CarryApp.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 16/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct ALP_Jevon_CarryApp: App {

    // Friend’s original ViewModels
    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var quizViewModel = QuizViewModel(type: "PHQ-9")
    @StateObject private var listJournalViewModel = ListJournalViewModel()
    @StateObject private var journalViewModel = JournalViewModel()

    // Your view models that can be initialized directly
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()

    // These depend on other view models, so we’ll initialize them lazily
    @StateObject private var breathingViewModel: BreathingViewModel
    @StateObject private var sessionHistoryViewModel: SessionHistoryViewModel

    init() {
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif

        // Initialize dependent view models
        let authVM = AuthViewModel(repository: FirebaseAuthRepository())
        _breathingViewModel = StateObject(wrappedValue: BreathingViewModel(musicPlayerViewModel: musicPlayerViewModel, authViewModel: authVM))
        _sessionHistoryViewModel = StateObject(wrappedValue: SessionHistoryViewModel(authViewModel: authVM))

        print("🔥 Firebase configured at: \(Date())")
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(authViewModel)
                .environmentObject(journalViewModel)
                .environmentObject(listJournalViewModel)
                .environmentObject(historyViewModel)
                .environmentObject(quizViewModel)
                .environmentObject(musicPlayerViewModel)
                .environmentObject(breathingViewModel)
                .environmentObject(sessionHistoryViewModel)
        }
    }
}
