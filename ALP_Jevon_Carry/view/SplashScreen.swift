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
                Image(systemName: "bolt.fill") // Ganti dengan logo aplikasi
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.yellow)
                Text("Jevon Care")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(.white)
                
                Spacer()
                Text("By Jevon Carry Group")
                    .font(.title3)
                    .fontWeight(.medium)
                    .padding(.bottom, 30)
                    .foregroundColor(.white)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("color1")) // Ubah di sini, misalnya .blue, .gray, atau Color(hex: ...)
                .ignoresSafeArea() // Supaya background penuh hingga ke safe area
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
