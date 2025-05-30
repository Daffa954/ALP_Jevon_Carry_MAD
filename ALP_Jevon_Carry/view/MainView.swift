//
//  MainView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

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
    
    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }
            
            BreathingSessionViewWrapper()
                .tabItem {
                    Label("Breathing", systemImage: "lungs.fill")
                }
            
            JournalView(userId: authViewModel.user?.uid ?? "")
                .tabItem {
                    Label("Journal", systemImage: "book")
                }
            
            UserProfileView(showLogin: $showAuthSheet)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .onAppear {
            showAuthSheet = !authViewModel.isSigneIn
        }
        .sheet(isPresented: $showAuthSheet) {
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}

struct BreathingSessionViewWrapper: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var breathingViewModel: BreathingViewModel?
    @State private var musicPlayerViewModel: MusicPlayerViewModel?
    @State private var showingSessionHistory = false
    @State private var sessionHistoryViewModel: SessionHistoryViewModel?
    @State private var previousSessionState = false
    
    var body: some View {
        Group {
            if let breathingViewModel = breathingViewModel {
                BreathingSessionView(
                    breathingViewModel: breathingViewModel,
                    showingSessionHistory: $showingSessionHistory
                )
                .onChange(of: breathingViewModel.isSessionActive) { oldValue, newValue in
                    let wasActive = previousSessionState
                    previousSessionState = newValue
                    if wasActive && !newValue && breathingViewModel.sessionTimeElapsed > 5 {
                        if sessionHistoryViewModel == nil {
                            sessionHistoryViewModel = SessionHistoryViewModel(authViewModel: authViewModel)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingSessionHistory = true
                        }
                    }
                }
                .onAppear {
                    previousSessionState = breathingViewModel.isSessionActive
                }
                .sheet(isPresented: $showingSessionHistory) {
                    if let historyVM = sessionHistoryViewModel {
                        SessionHistoryView(historyViewModel: historyVM)
                            .environmentObject(authViewModel)
                    } else {
                        SessionHistoryView(historyViewModel: SessionHistoryViewModel(authViewModel: authViewModel))
                            .environmentObject(authViewModel)
                    }
                }
            } else {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.2),
                                        Color.orange.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.blue.opacity(0.4),
                                        Color.orange.opacity(0.4)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            )
                    }
                    
                    VStack(spacing: 4) {
                        Text("Preparing your breathing session...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Setting up mindful experience")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.blue.opacity(0.1),
                            Color.white
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .onAppear {
            if breathingViewModel == nil {
                let musicPlayerVM = MusicPlayerViewModel()
                breathingViewModel = BreathingViewModel(
                    musicPlayerViewModel: musicPlayerVM,
                    authViewModel: authViewModel
                )
                musicPlayerViewModel = musicPlayerVM
                sessionHistoryViewModel = SessionHistoryViewModel(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(ListJournalViewModel())
        .environmentObject(JournalViewModel())
}
