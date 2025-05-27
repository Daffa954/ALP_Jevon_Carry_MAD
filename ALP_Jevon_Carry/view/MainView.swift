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

// Wrapper view that creates the view models and handles session completion
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
                    // Store the previous state for comparison
                    let wasActive = previousSessionState
                    previousSessionState = newValue
                    
                    // Detect when a session ends (was active, now inactive) and has meaningful duration
                    if wasActive && !newValue && breathingViewModel.sessionTimeElapsed > 5 {
                        // Create/update the session history view model when a session completes
                        if sessionHistoryViewModel == nil {
                            sessionHistoryViewModel = SessionHistoryViewModel(authViewModel: authViewModel)
                        }
                        
                        // Show history after a brief delay to allow for session completion animations
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingSessionHistory = true
                        }
                    }
                }
                .onAppear {
                    // Initialize session state tracking
                    previousSessionState = breathingViewModel.isSessionActive
                }
                .sheet(isPresented: $showingSessionHistory) {
                    if let historyVM = sessionHistoryViewModel {
                        SessionHistoryView(historyViewModel: historyVM)
                            .environmentObject(authViewModel)
                    } else {
                        // Fallback - create a new one if needed
                        SessionHistoryView(historyViewModel: SessionHistoryViewModel(authViewModel: authViewModel))
                            .environmentObject(authViewModel)
                    }
                }
            } else {
                // Elegant loading state while view models are being initialized
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.inhaleColor.opacity(0.2),
                                        AppColors.exhaleColor.opacity(0.2)
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
                                        AppColors.inhaleColor.opacity(0.4),
                                        AppColors.exhaleColor.opacity(0.4)
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
                            .foregroundColor(AppColors.lightPrimaryText)
                        
                        Text("Setting up mindful experience")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(AppColors.lightSecondaryText)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            AppColors.neutralColor.opacity(0.1),
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
                
                // Initialize session history view model
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
