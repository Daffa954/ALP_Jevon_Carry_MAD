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
                    Image("Image1").resizable().frame(maxWidth: .infinity, maxHeight: .infinity)

                }
                
                Text(registerClicked ? "Login" : "Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    
                
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
                    .autocapitalization(.none)
                    
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
                        .frame(height: 50)
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
        .padding(.horizontal, 20)
    }
}

// Custom Text Field Component
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}
// Hobby Chip Component
struct HobbyChip: View {
    let hobby: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(hobby)
                .font(.subheadline)
                .frame(width: 100, height: 36) // Ukuran seragam
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? Color.blue : Color(.systemGray3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            // Conditional field based on security state
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            // Show/Hide button
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

//password harus 8
#Preview {
    LoginRegisterSheet(
        showAuthSheet:
                .constant(true)
    )
    .environmentObject(
        AuthViewModel()
    )
}


