//
//  AddJournalView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct AddJournalView: View {
    @State private var journal = ""
    
    var body: some View {
        VStack{
            Text("My Journal")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            TextEditor(text: $journal)
                .frame(maxWidth: .infinity, maxHeight: 220)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.bottom)
            
            
            Button(action: {
                
            }){
                Text("Check Now")
                    .frame(maxWidth: .infinity)
                    .padding(4)
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    AddJournalView()
}
