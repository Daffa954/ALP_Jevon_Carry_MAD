//
//  UserProfileView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var showLogin: Bool
    
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button(action: {
                authViewModel.signOut()
                authViewModel.checkUserSession()
                showLogin = !authViewModel.isSigneIn
                
            }){
                Text("Logout")
                    .font(.title3)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    UserProfileView(showLogin: .constant(true))
        .environmentObject(AuthViewModel())
}
