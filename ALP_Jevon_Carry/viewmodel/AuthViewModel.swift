//
//  AuthViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 16/05/25.
//



import Foundation
import FirebaseAuth
import FirebaseDatabase

@MainActor
class AuthViewModel: ObservableObject{
    
    @Published var user: User?
    @Published var isSigneIn: Bool
    @Published var myUser: MyUser
    @Published var falseCredential: Bool
    
    init(){
        self.user = nil
        self.isSigneIn = false
        self.falseCredential = false
        self.myUser = MyUser()
        self.checkUserSession()
        
    }
    
    func checkUserSession(){
        self.user = Auth.auth().currentUser
        self.isSigneIn = self.user != nil
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }catch{
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
    
    func signIn() async {
        do{
            _ = try await Auth.auth().signIn(withEmail: myUser.email, password: myUser.password)
            DispatchQueue.main.async {
                self.falseCredential = false
            }
        }catch{
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }
    
    func singUp() async {
        let ref = Database.database().reference()
        do {
            let result = try await Auth.auth().createUser(withEmail: myUser.email, password: myUser.password)
            let uid = result.user.uid
            
            // Simpan data user ke Realtime Database
            let userData: [String: Any] = [
                "id": uid,
                "email": myUser.email,
                "name": myUser.name,
                "hobbies": myUser.hobbies
            ]

            try await ref.child("users").child(uid).setValue(userData)
            
            DispatchQueue.main.async {
                self.falseCredential = false
                self.user = result.user
                self.isSigneIn = true
            }
        } catch {
            print("Sign Up Error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                
            }
            
        }
    }
}
