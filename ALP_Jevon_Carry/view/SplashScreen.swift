//
//  SplashScreen.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
           MainView()
        } else {
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                    
                Text("Mindly")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, -20)
                    .foregroundColor(.white)
                
                Spacer()
                Text("By Jevon Carry Group")
                    .font(.callout)
                    .fontWeight(.medium)
                    .padding(.bottom, 50)
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("color1"))
                .ignoresSafeArea()
            .onAppear {
                // Waktu tampil splash screen dalam detik
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(
            AuthViewModel()
        )
}
