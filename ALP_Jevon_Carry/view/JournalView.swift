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
    @EnvironmentObject var journalVM: JournalViewModel
    var body: some View {
        NavigationStack{
            ScrollView{
                
                VStack{
                    Text("My Journal").font(.title).fontWeight(.bold).padding(.top,-40).foregroundStyle(Color("navyBlue"))
                    VStack{
                        Text("Your Weekly Stress Level")
                            .foregroundStyle(Color("skyBlue"))
                        Text("From your journal").padding(.bottom, 10)
                            .foregroundStyle(Color("skyBlue"))

                        JournalChartView()
                    }.padding(.top, -5).padding(.bottom,30)
                    
                    VStack{
                        Text("History")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("navyBlue"))
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
        }
    }
}

#Preview {
    JournalView(userId: "fBdMKF5GIvMuufer7JqzgPgVwEI2")
        .environmentObject(JournalViewModel())
}
