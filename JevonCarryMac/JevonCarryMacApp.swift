//
//  JevonCarryMacApp.swift
//  JevonCarryMac
//
//  Created by Daffa Khoirul on 29/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

//struct JevonCarryMacApp: App {
//    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
//    @StateObject private var historyViewModel = HistoryViewModel()
//    @StateObject private var quizViewModel = QuizViewModel(type: "PHQ-9")
//    @StateObject private var listJournalViewModel = ListJournalViewModel()
//    
//    @StateObject private var journalViewModel = JournalViewModel()
//    init(){
//        if let plistPath = Bundle.main.path(forResource: "GoogleService-Info-macOS", ofType: "plist"),
//           let firebaseOptions = FirebaseOptions(contentsOfFile: plistPath) {
//            FirebaseApp.configure(options: firebaseOptions)
//        } else {
//            fatalError("Could not load GoogleService-Info-macOS.plist. Check its name and target membership.")
//        }
//#if DEBUG
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//#endif
//    }
//    var body: some Scene {
//        WindowGroup {
//            SplashScreenView()
//                .environmentObject(authViewModel)
//        }
//    }
//}
import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct JevonCarryMacApp: App {
    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
    @StateObject private var historyViewModel = HistoryViewModel()
    @StateObject private var quizViewModel = QuizViewModel(type: "PHQ-9")
    @StateObject private var listJournalViewModel = ListJournalViewModel()
    @StateObject private var journalViewModel = JournalViewModel()

    init() {
        
            if let plistPath = Bundle.main.path(forResource: "GoogleService-Info-macOs", ofType: "plist"), // Pastikan nama file ini benar
               let firebaseOptions = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: firebaseOptions)
            } else {
                fatalError("Error: GoogleService-Info-macOS.plist tidak ditemukan atau tidak valid.")
            }
         
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
