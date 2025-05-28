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
        TabView{
            HomeView().tabItem{
                    Label("Home", systemImage: "house")
                }
            
            
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
        .onAppear {
            showAuthSheet = !authViewModel.isSigneIn
        }.sheet(isPresented: $showAuthSheet){
            LoginRegisterSheet(showAuthSheet: $showAuthSheet)
        }
    }
}


#Preview {
    MainView()
        .environmentObject(AuthViewModel())
        .environmentObject(ListJournalViewModel())
        .environmentObject(JournalViewModel())
}
