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
    @State private var hoveredButton: String?
    
    // Color constants from your palette
    private let skyBlue = Color(hex: "#498FD0")
    private let navyBlue = Color(hex: "#2C3E50")
    private let coralOrange = Color(hex: "#F27E63")
    private let lightGray = Color(hex: "#F5F7FA")
    private let emeraldGreen = Color(hex: "#3DBE8B")
    
    // Flexible columns for hobby tags
    let columns = [GridItem(.adaptive(minimum: 100))]
    
    var body: some View {
        NavigationStack {
            ZStack {
                lightGray
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading profile...")
                        .progressViewStyle(CircularProgressViewStyle(tint: skyBlue))
                        .scaleEffect(1.5)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header Section
                            VStack {
                                Text("My Profile")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(navyBlue)
                                
                                Text("Manage your account information")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                            
                            // Profile Card
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(skyBlue)
                                        .padding(.trailing, 16)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(authViewModel.myUser.name)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(navyBlue)
                                        
                                        Text(authViewModel.myUser.email)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                                
                                Divider()
                                    .background(navyBlue.opacity(0.2))
                                
                                // Hobbies Section
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Hobbies & Interests")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(navyBlue)
                                    
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
                                                    .background(skyBlue.opacity(0.15))
                                                    .foregroundColor(skyBlue)
                                                    .cornerRadius(15)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: navyBlue.opacity(0.1), radius: 5, x: 0, y: 2)
                            
                            // Actions Section
                            VStack(spacing: 12) {
                                Button(action: {
                                    showEditProfile = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .foregroundColor(skyBlue)
                                        Text("Edit Profile")
                                            .foregroundColor(navyBlue)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(hoveredButton == "edit" ? skyBlue.opacity(0.1) : Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(skyBlue.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onHover { hovering in
                                    hoveredButton = hovering ? "edit" : nil
                                }
                                
                                Button(role: .destructive, action: {
                                    showLogoutAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.square")
                                            .foregroundColor(coralOrange)
                                        Text("Log Out")
                                            .foregroundColor(coralOrange)
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(hoveredButton == "logout" ? coralOrange.opacity(0.1) : Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(coralOrange.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onHover { hovering in
                                    hoveredButton = hovering ? "logout" : nil
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: 600)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(navyBlue.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
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
                        isLoading = true
                        do {
                            try await authViewModel.fetchUserProfile(userID: newUID)
                        } catch {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                        isLoading = false
                    }
                }
            }
        }
        .frame(minWidth: 500, idealWidth: 600, maxWidth: .infinity,
               minHeight: 500, idealHeight: 600, maxHeight: .infinity)
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview
#Preview {
    UserProfileView(showLogin: .constant(false))
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
}
