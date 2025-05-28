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
   
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var listJournalViewModel = ListJournalViewModel()
    @StateObject private var journalViewModel = JournalViewModel()
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
    @StateObject private var breathingViewModel: BreathingViewModel
    @StateObject private var sessionHistoryViewModel: SessionHistoryViewModel
    
    init(){
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
        
        // Initialize ViewModels with dependencies
        let authVM = AuthViewModel()
        let musicVM = MusicPlayerViewModel()
        
        _authViewModel = StateObject(wrappedValue: authVM)
        _musicPlayerViewModel = StateObject(wrappedValue: musicVM)
        _breathingViewModel = StateObject(wrappedValue: BreathingViewModel(musicPlayerViewModel: musicVM, authViewModel: authVM))
        _sessionHistoryViewModel = StateObject(wrappedValue: SessionHistoryViewModel(authViewModel: authVM))
        
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
