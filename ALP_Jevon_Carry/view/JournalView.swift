//
//  JournalView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct JournalView: View {
    @State var isAdding: Bool = false
    @State var userId: String
    @EnvironmentObject var listJournalVM: ListJournalViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                VStack{
                    
                    Text("My Journal").font(.title).fontWeight(.bold).padding(.top,-40).foregroundStyle(Color("navyBlue"))
                    Text(authVM.user?.uid ?? "")
                    VStack{
                        Text("Your Weekly Stress Level")
                            .foregroundStyle(Color("skyBlue"))
                        Text("From your journal").padding(.bottom, 10)
                            .foregroundStyle(Color("skyBlue"))
                        
                        JournalChartView(journalData: listJournalVM.allJournalThisWeek)

                    }.padding(.top, -5).padding(.bottom,30)
                    
                    VStack{
                        Text("History")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("navyBlue"))
                    }
                    VStack {
                        ForEach(listJournalVM.allJournalThisWeek) { journal in
                            Text(journal.title) // Contoh menampilkan title
                            Text("\(journal.date)")
                        }
                    }
                    
                }
                Spacer()
            }.padding(.horizontal,25)
            
            
                .toolbar {
                    Button(action: {
                        isAdding = true
                    }) {
                        Text("+")
                            .font(.title).foregroundStyle(Color("navyBlue"))
                    }.accessibilityIdentifier( "addBookButton" )
                }
                .navigationDestination(isPresented: $isAdding, destination: {AddJournalView(isAddJournal: $isAdding, userID: userId)})
            
                .onChange(of: authVM.user?.uid ?? "", initial: true) { oldUID, newUID in
                    if !newUID.isEmpty {
                        listJournalVM.fetchJournalThisWeek(userID: newUID)
                    } else {
                        listJournalVM.allJournalThisWeek = []
                    }
                }
        }
    }
}

#Preview {
    JournalView(userId: "fBdMKF5GIvMuufer7JqzgPgVwEI2")
        .environmentObject(ListJournalViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(JournalViewModel())
}
