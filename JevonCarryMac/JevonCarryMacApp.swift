//
//  JevonCarryMacApp.swift
//  JevonCarryMac
//
//  Created by Daffa Khoirul on 29/05/25.
//

import SwiftUI
import Firebase
import FirebaseAppCheck

@main
struct JevonCarryMacApp: App {
    @StateObject private var authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
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
        }
    }
}
