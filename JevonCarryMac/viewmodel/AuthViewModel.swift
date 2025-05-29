//
//  AuthViewModel.swift
//  JevonCarryMac
//
//  Created by Daffa Khoirul on 29/05/25.
//





import Foundation
import FirebaseAuth
import FirebaseDatabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isSigneIn: Bool
    @Published var myUser: MyUser
    @Published var falseCredential: Bool

    private let repository: FirebaseAuthRepository

    init(repository: FirebaseAuthRepository) {
        self.repository = repository
        self.user = nil
        self.isSigneIn = false
        self.falseCredential = false
        self.myUser = MyUser()
        self.checkUserSession()
    }

    func checkUserSession() {
        self.user = repository.getCurrentUser()
        self.isSigneIn = self.user != nil
    }

    func signOut() {
        do {
            try repository.signOut()
            self.user = nil
            self.isSigneIn = false
        } catch {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }

    func signIn() async {
        do {
            let result = try await repository.signIn(email: myUser.email, password: myUser.password)
            let profile = try await repository.fetchUserProfile(userID: result.user.uid)
            DispatchQueue.main.async {
                self.user = result.user
                self.myUser = profile
                self.falseCredential = false
                self.isSigneIn = true
            }
        } catch {
            DispatchQueue.main.async {
                self.falseCredential = true
            }
        }
    }

    func fetchUserProfile(userID: String) async {
        do {
            let profile = try await repository.fetchUserProfile(userID: userID)
            DispatchQueue.main.async {
                self.myUser = profile
            }
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
        }
    }

    func singUp() async {
        do {
            let result = try await repository.signUp(email: myUser.email, password: myUser.password)
            var userToSave = myUser
            userToSave.uid = result.user.uid
            try await repository.saveUserProfile(user: userToSave)

            DispatchQueue.main.async {
                self.user = result.user
                self.myUser = userToSave
                self.isSigneIn = true
                self.falseCredential = false
            }
        } catch {
            print("Sign Up Error: \(error.localizedDescription)")
        }
    }
}
