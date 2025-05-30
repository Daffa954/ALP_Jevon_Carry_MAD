//
//  LoginView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 16/05/25.
//


//import SwiftUI
//
//struct LoginRegisterSheet: View {
//    @Binding var showAuthSheet: Bool
//    @EnvironmentObject var authVM: AuthViewModel
//    @State var registerClicked: Bool = true
//    @State private var selectedHobbies: [String] = []
//    
//    // Sample hobby data
//    let hobbies = [
//        "Reading", "Sports", "Music", "Gaming",
//        "Cooking", "Photography", "Traveling", "Art",
//        "Dancing", "Programming", "Movies", "Fitness"
//    ]
//    var body: some View {
//        ZStack {
//            // Background
//            Color("lightGray1")
//                .ignoresSafeArea()
//            
//            // Content
//            
//            VStack(spacing: 20) {
//                // Header
//                if registerClicked {
//                    Image("Image1").resizable()
//                        .scaledToFit()
//                        .frame(width: 200)
//                        .padding(.top, 20)
//
//                }
//                
//                if !registerClicked {
//                    Spacer()
//                }
//                
//                Text(registerClicked ? "Login" : "Register")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    
//                
//                // Form Fields
//                VStack(spacing: 16) {
//                    if !registerClicked {
//                        CustomTextField(
//                            placeholder: "Name",
//                            text: $authVM.myUser.name
//                        )
//                        VStack(alignment: .leading) {
//                            Text("Select Your Hobbies")
//                                .font(.headline)
//                            
//                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
//                                ForEach(hobbies, id: \.self) { hobby in
//                                    HobbyChip(
//                                        hobby: hobby,
//                                        isSelected: selectedHobbies.contains(hobby)
//                                    ) {
//                                        if selectedHobbies.contains(hobby) {
//                                            selectedHobbies.removeAll { $0 == hobby }
//                                        } else {
//                                            selectedHobbies.append(hobby)
//                                        }
//                                        authVM.myUser.hobbies = selectedHobbies // Update view model
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.vertical)
//                        
//                    }
//                    
//                    CustomTextField(
//                        placeholder: "Email",
//                        text: $authVM.myUser.email
//                    )
//                    
//                    
//                    
//                    CustomSecureField(
//                        placeholder: "Password",
//                        text: $authVM.myUser.password
//                    )
//                    
//                    if authVM.falseCredential {
//                        Text("Invalid Username and Password")
//                            .foregroundColor(.red)
//                            .font(.caption)
//                    }
//                }
//                .padding(.horizontal)
//                
//                // Action Button
//                Button(action: {
//                    Task {
//                        if registerClicked {
//                            await authVM.signIn()
//                            if !authVM.falseCredential {
//                                authVM.checkUserSession()
//                                showAuthSheet = !authVM.isSigneIn
//                                authVM.myUser = MyUser()
//                            }
//                        } else {
//                            await authVM.singUp()
//                            if !authVM.falseCredential {
//                                authVM.checkUserSession()
//                                showAuthSheet = !authVM.isSigneIn
//                                authVM.myUser = MyUser()
//                            }
//                        }
//                    }
//                }) {
//                    Text(registerClicked ? "Login" : "Register")
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 32)
//                }
//                .buttonStyle(.borderedProminent)
//                .padding(.horizontal)
//                
//                Spacer()
//                
//                // Toggle Button
//                Button(action: {
//                    withAnimation {
//                        registerClicked.toggle()
//                        authVM.falseCredential = false
//                    }
//                }) {
//                    Text(registerClicked ? "Don't have an account? Register" : "Already have an account? Login")
//                        .foregroundColor(.blue)
//                }
//                .padding(.bottom)
//                Spacer()
//            }
//           
//        }
//        .interactiveDismissDisabled(true)
//        .padding(.horizontal, 20)    }
//}
//
//// Custom Text Field Component
//
//
//
////password harus 8
//#Preview {
//    LoginRegisterSheet(
//        showAuthSheet:
//                .constant(true)
//    )
//    .environmentObject(
//        AuthViewModel(repository: FirebaseAuthRepository())
//    )
//}
//
//
import SwiftUI

struct LoginRegisterSheet: View {
    @Binding var showAuthSheet: Bool
    @EnvironmentObject var authVM: AuthViewModel
    @State var registerClicked: Bool = true
    @State private var selectedHobbies: [String] = []
    
    let hobbies = [
        "Reading", "Sports", "Music", "Gaming",
        "Cooking", "Photography", "Traveling", "Art",
        "Dancing", "Programming", "Movies", "Fitness"
    ]
    
    var body: some View {
        ZStack {
            // Dark background for macOS
            Color.black
                .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    if registerClicked {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .foregroundColor(.orange)
                            .padding(.top, 40)
                    }
                    
                    Text(registerClicked ? "Login" : "Register")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        if !registerClicked {
                            CustomTextField(
                                placeholder: "Name",
                                text: $authVM.myUser.name,
                                backgroundColor: Color.gray.opacity(0.2),
                                textColor: .white
                            )
                            
                            VStack(alignment: .leading) {
                                Text("Select Your Hobbies")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                                    ForEach(hobbies, id: \.self) { hobby in
                                        HobbyChip(
                                            hobby: hobby,
                                            isSelected: selectedHobbies.contains(hobby),
                                            foregroundColor: .white,
                                            selectedColor: .orange
                                        ) {
                                            if selectedHobbies.contains(hobby) {
                                                selectedHobbies.removeAll { $0 == hobby }
                                            } else {
                                                selectedHobbies.append(hobby)
                                            }
                                            authVM.myUser.hobbies = selectedHobbies
                                        }
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        CustomTextField(
                            placeholder: "Email",
                            text: $authVM.myUser.email,
                            backgroundColor: Color.gray.opacity(0.2),
                            textColor: .white
                        )
                        
                        CustomSecureField(
                            placeholder: "Password",
                            text: $authVM.myUser.password,
                            backgroundColor: Color.gray.opacity(0.2),
                            textColor: .white
                        )
                        
                        if authVM.falseCredential {
                            Text("Invalid Username and Password")
                                .foregroundColor(.orange)
                                .font(.caption)
                        }
                    }
                    .padding(.horizontal, 40)
                    
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
                            .frame(height: 44)
                            .background(Color.orange)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Toggle Button
                    Button(action: {
                        withAnimation {
                            registerClicked.toggle()
                            authVM.falseCredential = false
                        }
                    }) {
                        Text(registerClicked ? "Don't have an account? Register" : "Already have an account? Login")
                            .foregroundColor(.orange)
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 20)
            }
        }
        .interactiveDismissDisabled(true)
    }
}

// Custom Text Field Component for macOS
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var backgroundColor: Color
    var textColor: Color
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 1)
            )
    }
}

// Custom Secure Field Component for macOS
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String
    var backgroundColor: Color
    var textColor: Color
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(8)
            .foregroundColor(textColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange, lineWidth: 1)
            )
    }
}

// Hobby Chip Component for macOS
struct HobbyChip: View {
    var hobby: String
    var isSelected: Bool
    var foregroundColor: Color
    var selectedColor: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(hobby)
                .font(.caption)
                .padding(8)
                .background(isSelected ? selectedColor : Color.clear)
                .foregroundColor(isSelected ? .black : foregroundColor)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? selectedColor : Color.gray, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginRegisterSheet(
        showAuthSheet: .constant(true)
    )
    .environmentObject(
        AuthViewModel(repository: FirebaseAuthRepository())
    )
    .frame(width: 800, height: 600)
}
