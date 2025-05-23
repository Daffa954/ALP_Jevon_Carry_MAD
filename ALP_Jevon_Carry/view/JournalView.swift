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
            
            Spacer()
        }.padding()
    }
}

#Preview {
    JournalView()
}
