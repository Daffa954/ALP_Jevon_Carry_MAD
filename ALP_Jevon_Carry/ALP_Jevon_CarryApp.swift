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
