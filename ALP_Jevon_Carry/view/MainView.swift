//
//  MainView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var listJournalViewModel: ListJournalViewModel
    @State var showAuthSheet = false
    
    // Breathing session related state
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
    @State private var breathingViewModel: BreathingViewModel?
    @State private var sessionHistoryViewModel: SessionHistoryViewModel?
    @State private var showingSessionHistory = false
    
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }
            
            // Direct breathing session view
            Group {
                if let breathingVM = breathingViewModel {
                    BreathingSessionView(
                        breathingViewModel: breathingVM,
                        showingSessionHistory: $showingSessionHistory
                    )
                } else {
                    // Simple loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color("AccentColor"))
                        
                        Text("Preparing your breathing session...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color("skyBlue").opacity(0.1),
                                Color.white
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .tabItem {
                Label("Breathing", systemImage: "lungs.fill")
            }
            
            JournalView(userId: authViewModel.user?.uid ?? "")
                .tabItem{
                    Label("Journal", systemImage: "book")
                }
            
            UserProfileView(showLogin: $showAuthSheet)
                .tabItem{
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .onAppear {
            // Show auth sheet if not signed in
            showAuthSheet = !authViewModel.isSigneIn
            
            // Initialize breathing view model if needed
            if breathingViewModel == nil {
                breathingViewModel = BreathingViewModel(
                    musicPlayerViewModel: musicPlayerViewModel,
                    authViewModel: authViewModel
                )
                sessionHistoryViewModel = SessionHistoryViewModel(authViewModel: authViewModel)
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
        .sheet(isPresented: $showingSessionHistory) {
            if let historyVM = sessionHistoryViewModel {
                SessionHistoryView(historyViewModel: historyVM)
                    .environmentObject(authViewModel)
            }
        }
    }
}


#Preview {
    MainView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(ListJournalViewModel())
        .environmentObject(JournalViewModel())
        .environmentObject(QuizViewModel(type: "PHQ-9"))

}
