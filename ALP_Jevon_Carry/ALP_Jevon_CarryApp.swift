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

    // Friend's original ViewModels
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var listJournalViewModel = ListJournalViewModel()
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
        let tempAuthVM = AuthViewModel()
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
        }
    }
}
