//
//  MainView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var showAuthSheet = false
    var body: some View {
        TabView{
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                    
                }
            JournalView()
                .tabItem{
                    Label("Journal", systemImage: "book")
                }
            
            SchedulleView().tabItem{
                Label("Breathing", systemImage: "lungs.fill")
            }
            
            QuizView().tabItem {
                Label("Check Your Mental Health", systemImage: "list.bullet.clipboard")
            }
            
            UserProfileView()
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
}
