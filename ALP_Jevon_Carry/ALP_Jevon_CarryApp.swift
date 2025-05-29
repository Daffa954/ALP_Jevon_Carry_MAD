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
   
    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var quizViewModel = QuizViewModel(type: "PHQ-9")
    @StateObject private var listJournalViewModel = ListJournalViewModel()

    @StateObject private var journalViewModel = JournalViewModel()
    init(){
        FirebaseApp.configure()
        #if DEBUG
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif
    }
    var body: some Scene {
        WindowGroup {
           SplashScreenView()
                .environmentObject(authViewModel)
                .environmentObject(journalViewModel)
                .environmentObject(listJournalViewModel)
                .environmentObject(historyViewModel)
                .environmentObject(quizViewModel)
        }
    }
}
