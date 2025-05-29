import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var showLogin: Bool
    @State private var showLogoutAlert = false
    @State private var isLoading = false
    @State private var showEditProfile = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // Flexible columns for hobby tags
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                if isLoading {
                    ProgressView("Loading profile...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack() {
                            // Header Section
                            VStack() {
                                Text("My Profile")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.primary)
                                
                                Text("Manage your account information")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom, 8)
                            
                            // Profile Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 12)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(authViewModel.myUser.name)
                                            .font(.title2)
                                            .bold()
                                        
                                        Text(authViewModel.myUser.email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                                
                                Divider()
                                
                                // Hobbies Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hobbies & Interests")
                                        .font(.headline)
                                        .bold()
                                    
                                    if authViewModel.myUser.hobbies.isEmpty {
                                        Text("None added")
                                            .foregroundColor(.secondary)
                                    } else {
                                        LazyVGrid(columns: columns, spacing: 10) {
                                            ForEach(authViewModel.myUser.hobbies, id: \.self) { hobby in
                                                Text(hobby)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.1))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(15)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            // Actions Section
                            VStack(spacing: 16) {
                                Button(action: {
                                    showEditProfile = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Profile")
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .foregroundColor(.primary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                }
                                
                                Button(role: .destructive, action: {
                                    showLogoutAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.square")
                                        Text("Log Out")
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(10)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authViewModel.signOut()
                    showLogin = true
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .onChange(of: authViewModel.user?.uid ?? "", initial: true) { oldUID, newUID in
                if !newUID.isEmpty {
                    Task {
                        do {
                            try await authViewModel.fetchUserProfile(userID: newUID)
                        } catch {
                            print("Error loading: \(error.localizedDescription)")
                        }
                    }
                }
            }
            
        }
    }
}

// Preview
#Preview {
    UserProfileView(showLogin: .constant(false))
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
    
}

