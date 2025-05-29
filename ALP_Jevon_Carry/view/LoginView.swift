//
//  LoginView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 16/05/25.
//


import SwiftUI

struct LoginRegisterSheet: View {
    @Binding var showAuthSheet: Bool
    @EnvironmentObject var authVM: AuthViewModel
    @State var registerClicked: Bool = true
    @State private var selectedHobbies: [String] = [] // Track selected hobbies
    
    // Sample hobby data
    let hobbies = [
        "Reading", "Sports", "Music", "Gaming",
        "Cooking", "Photography", "Traveling", "Art",
        "Dancing", "Programming", "Movies", "Fitness"
    ]
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Content
            
            VStack(spacing: 20) {
                // Header
                if registerClicked {
                    Image("Image1").resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .padding(.top, 20)

                }
                
                if !registerClicked {
                    Spacer()
                }
                
                Text(registerClicked ? "Login" : "Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    
                
                // Form Fields
                VStack(spacing: 16) {
                    if !registerClicked {
                        CustomTextField(
                            placeholder: "Name",
                            text: $authVM.myUser.name
                        )
                        VStack(alignment: .leading) {
                            Text("Select Your Hobbies")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(hobbies, id: \.self) { hobby in
                                    HobbyChip(
                                        hobby: hobby,
                                        isSelected: selectedHobbies.contains(hobby)
                                    ) {
                                        if selectedHobbies.contains(hobby) {
                                            selectedHobbies.removeAll { $0 == hobby }
                                        } else {
                                            selectedHobbies.append(hobby)
                                        }
                                        authVM.myUser.hobbies = selectedHobbies // Update view model
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                        
                    }
                    
                    CustomTextField(
                        placeholder: "Email",
                        text: $authVM.myUser.email
                    )
                    .keyboardType(.emailAddress)
                    
                    
                    CustomSecureField(
                        placeholder: "Password",
                        text: $authVM.myUser.password
                    )
                    
                    if authVM.falseCredential {
                        Text("Invalid Username and Password")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal)
                
                // Action Button
                Button(action: {
                    Task {
                        if registerClicked {
                            await authVM.signIn()
                            if !authVM.falseCredential {
                                authVM.checkUserSession()
                                showAuthSheet = !authVM.isSigneIn
                                authVM.myUser = MyUser()
                            }
                        } else {
                            await authVM.singUp()
                            if !authVM.falseCredential {
                                authVM.checkUserSession()
                                showAuthSheet = !authVM.isSigneIn
                                authVM.myUser = MyUser()
                            }
                        }
                    }
                }) {
                    Text(registerClicked ? "Login" : "Register")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Spacer()
                
                // Toggle Button
                Button(action: {
                    withAnimation {
                        registerClicked.toggle()
                        authVM.falseCredential = false
                    }
                }) {
                    Text(registerClicked ? "Don't have an account? Register" : "Already have an account? Login")
                        .foregroundColor(.blue)
                }
                .padding(.bottom)
                Spacer()
            }
           
        }
        .interactiveDismissDisabled(true)
        .padding(.horizontal, 20)    }
}

// Custom Text Field Component



//password harus 8
#Preview {
    LoginRegisterSheet(
        showAuthSheet:
                .constant(true)
    )
    .environmentObject(
        AuthViewModel(repository: FirebaseAuthRepository())
    )
}


