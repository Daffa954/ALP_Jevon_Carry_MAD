//
//  JournalView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct JournalView: View {
    @State var isAdding: Bool = false
    var body: some View {
        NavigationStack{
            ScrollView{
                
                VStack{
                    Text("My Journal").font(.title).fontWeight(.bold).padding(.top,-40)
                    VStack{
                        Text("Your Weekly Stress Level")
                            .fontWeight(.ultraLight)
                        Text("From your journal").padding(.bottom, 10)
                            .fontWeight(.ultraLight)

                        JournalChartView()
                    }.padding(.top, -5).padding(.bottom,30)
                    
                    VStack{
                        Text("History")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    
                }
                Spacer()
            }.padding(.horizontal,25)
            
            
                .toolbar {
                    Button(action: {
                        isAdding = true
                    }) {
                        Text("+")
                            .font(.title)
                    }.accessibilityIdentifier( "addBookButton" )
                }
                .navigationDestination(isPresented: $isAdding, destination: {AddJournalView(isAddJournal: $isAdding)})
        }
    }
}

#Preview {
    JournalView()
}
