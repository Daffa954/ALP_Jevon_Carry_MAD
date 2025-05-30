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
    @State var selectedTabItem: TabItemEnum = .home
    
    var body: some View {
        TabView(selection: $selectedTabItem){
            HomeView(tab: $selectedTabItem).tabItem{
                    Label("Home", systemImage: "house")
                }
            .tag(TabItemEnum.home)
            
            
            SchedulleView().tabItem{
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
//        .onChange(of: authViewModel.isSigneIn) { isSignedIn in
//            showAuthSheet = !isSignedIn
//        }.sheet(isPresented: $showAuthSheet){
//            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
//        }
        .onAppear {
            showAuthSheet = !authViewModel.isSigneIn
            selectedTabItem = .schedule
        }
        .onChange(of: authViewModel.isSigneIn) { isSignedIn in
            showAuthSheet = !isSignedIn
        }
        .sheet(isPresented: $showAuthSheet){
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}


#Preview {
    MainView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(ListJournalViewModel())
        .environmentObject(JournalViewModel())
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())

}
