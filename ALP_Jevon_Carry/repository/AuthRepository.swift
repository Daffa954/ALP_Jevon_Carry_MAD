//
//  AuthRepository.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 28/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import Foundation
import FirebaseAuth



class FirebaseAuthRepository {
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }

    func fetchUserProfile(userID: String) async throws -> MyUser {
        let ref = Database.database().reference().child("users").child(userID)
        let snapshot = try await ref.getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }

        return MyUser(
            uid: value["id"] as? String ?? "",
            name: value["name"] as? String ?? "",
            email: value["email"] as? String ?? "",
            hobbies: value["hobbies"] as? [String] ?? [""],
            
        )
    }

    func saveUserProfile(user: MyUser) async throws {
        let ref = Database.database().reference().child("users").child(user.uid)
        let userData: [String: Any] = [
            "id": user.uid,
            "email": user.email,
            "name": user.name,
            "hobbies": user.hobbies.isEmpty ? [""] : user.hobbies
        ]
        try await ref.setValue(userData)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
