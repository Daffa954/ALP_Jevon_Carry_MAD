//
//  JournalView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct JournalView: View {
    
    
    var body: some View {
        VStack{
            HStack{
                Text("My Journal")
                    .font(.title)
                    .fontWeight(.bold)
               
            }
            
            ZStack{
                Rectangle()
                    .frame(height: 220)
                    .cornerRadius(20)
                    .padding(.top)
                Text("Buat Grafik / History")
                    .foregroundStyle(.white)
                    .font(.title)
            }
            
            HStack{
                Rectangle()
                    .foregroundStyle(.yellow)
            }
            
            
            
            Spacer()
        }.padding()
    }
}

#Preview {
    JournalView()
}
