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
    
    // Define custom colors from your palette
    private let primaryBlue = Color(hex: "#498FD0") // Sky Blue
    private let navyBlue = Color(hex: "#2C3E50")    // Navy Blue
    private let coralOrange = Color(hex: "#F27E63") // Coral Orange
    private let lightGray = Color(hex: "#F5F7FA")   // Light Gray
    private let emeraldGreen = Color(hex: "#3DBE8B") // Emerald Green
    
    // Flexible columns for hobby tags
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    ProgressView("Loading profile...")
                        .progressViewStyle(CircularProgressViewStyle()) // macOS default is fine
                        .scaleEffect(1.0) // No need for larger scale on macOS usually
                } else {
                    ScrollView {
                        VStack(spacing: 24) { // Increased spacing for a more open feel on desktop
                            // Header Section
                            VStack(alignment: .leading, spacing: 4) { // Align header text to leading
                                Text("My Profile")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(navyBlue)
                                
                                Text("Manage your account information")
                                    .font(.title3) // Slightly larger subheadline for macOS
                                    .foregroundColor(navyBlue)
// System secondary color for good readability in both modes
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Align header to leading
                            .padding(.bottom, 8)
                            .padding(.horizontal,25)
                            
                            // Profile Card
                            VStack(alignment: .leading, spacing: 20) { // Increased spacing within card
                                HStack(spacing: 16) { // Increased spacing in HStack
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 80, height: 80) // Larger icon for macOS
                                        .foregroundColor(primaryBlue) // Primary color for the icon
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(authViewModel.myUser.name)
                                            .font(.title) // Larger name font
                                            .fontWeight(.semibold)
                                            .foregroundColor(navyBlue)
                                        Text(authViewModel.myUser.email)
                                            .font(.callout) // Slightly smaller than subheadline
                                            .foregroundColor(.gray) // Gray for email, good for both modes
                                    }
                                    Spacer()
                                }
                                
                                Divider()
                                    .background(Color.gray.opacity(0.3)) // Lighter divider
                                
                                // Hobbies Section
                                VStack(alignment: .leading, spacing: 12) { // Increased spacing
                                    Text("Hobbies & Interests")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(navyBlue)
                                    
                                    if authViewModel.myUser.hobbies.isEmpty {
                                        Text("None added")
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                    } else {
                                        LazyVGrid(columns: columns, spacing: 10) {
                                            ForEach(authViewModel.myUser.hobbies, id: \.self) { hobby in
                                                Text(hobby)
                                                    .font(.caption)
                                                    .padding(.horizontal, 14) // Slightly more padding
                                                    .padding(.vertical, 8)
                                                    .background(primaryBlue.opacity(0.15)) // Use primary blue with more opacity
                                                    .foregroundColor(primaryBlue)
                                                    .cornerRadius(20) // More rounded corners for tags
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(25) // More padding for the entire card
                            .background(Color.white.opacity(0.9)) // Slightly transparent white background for card in light mode
                            .cornerRadius(15) // More rounded corners for the card
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4) // Softer, more pronounced shadow
                            .padding(.horizontal) // Add horizontal padding to the card
                            
                            // Actions Section
                            VStack(spacing: 12) { // Tighter spacing for buttons
//                                Button(action: {
//                                    showEditProfile = true
//                                }) {
//                                    HStack {
//                                        Image(systemName: "pencil")
//                                            .font(.title3) // Larger icon
//                                        Text("Edit Profile")
//                                            .font(.body)
//                                        Spacer()
//                                        Image(systemName: "chevron.right")
//                                    }
//                                    .contentShape(Rectangle()) // Make the whole area tappable
//                                }
//                                .buttonStyle(ProfileButtonStyle(foregroundColor: navyBlue)) // Custom button style
                                
                                Button(role: .destructive, action: {
                                    showLogoutAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.left.square")
                                            .font(.title3)
                                        Text("Log Out")
                                            .font(.body)
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(ProfileButtonStyle(foregroundColor: coralOrange)) // Accent color for destructive action
                            }
                            .padding(.horizontal) // Add horizontal padding to actions
                            
                            Spacer()
                        }
                        .padding(.vertical) // Add vertical padding to the scroll view content
                    }
                    .background(lightGray.ignoresSafeArea()) // Use Light Gray for the background
                }
            }
            .navigationTitle("") // Hide default navigation title
            
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
                            isLoading = true // Set loading to true before fetching
                            try await authViewModel.fetchUserProfile(userID: newUID)
                        } catch {
                            print("Error loading: \(error.localizedDescription)")
                            errorMessage = "Failed to load profile: \(error.localizedDescription)"
                            showErrorAlert = true
                        }
                        isLoading = false // Set loading to false after fetching
                    }
                }
            }
        }
    }
}

// Custom ButtonStyle for consistent appearance
struct ProfileButtonStyle: ButtonStyle {
    var foregroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .background(Color.clear) // Clear background for button area
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(foregroundColor.opacity(0.5), lineWidth: 1) // Subtle border
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// Extension to allow Hex String for Color
extension Color {
    init(hex: String) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

// Preview
#Preview {
    UserProfileView(showLogin: .constant(false))
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
}
