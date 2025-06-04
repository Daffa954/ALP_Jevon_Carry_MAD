
import SwiftUI

struct HomeView: View {
    @State private var selectedQuizType: String = ""
    let cornerRadius: CGFloat = 30 // Still defined, but used strategically
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showQuizPHQ = false
    @State private var showQuizGAD = false
    @State private var showQuizHistory = false
    

    @Environment(\.colorScheme) var colorScheme // For dark mode adaptation

    var body: some View {
        NavigationStack {
            ZStack { // Use ZStack for potential background effects
                // Overall background for the HomeView
                // Option 1: Use your lightGray for light mode, and a custom dark color for dark mode
                (colorScheme == .dark ? Color.white : Color.white)
                    .ignoresSafeArea()
                // Option 2 (Recommended for macOS): Use Material for a modern adaptive blur effect
                // Material.regular // Or Material.thin, Material.thick, etc.
                //    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) { // Keep spacing 0 initially as inner sections have padding
                        // Header Section
                        headerSection
                            .padding(.bottom, 20) // Add some space below header
                        
                        // Main Content Container (with rounded top corners and adapting background)
                        VStack(spacing: 30) { // Increased spacing for a desktop feel
                            // Fresh Start Section
                            freshStartSection
                            
                            // Quiz Cards Section
                            VStack(alignment: .leading, spacing: 25) { // Align text to leading, increased spacing
                                VStack(alignment: .leading, spacing: 8) { // Align text to leading
                                    Text("Check Your Mental Health")
                                        .font(.title2) // Slightly larger, more prominent
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("navyBlue")) // Navy Blue for strong headings
                                    
                                    Text("For best results, this test is limited to one session per week.")
                                        .font(.callout) // Clearer text
                                        .foregroundColor(Color("navyBlue")) // Adapts automatically to dark/light mode
                                        .multilineTextAlignment(.leading) // Align text to leading
                                }
                                .padding(.horizontal, 20) // Padding for this text block
                                
                                // Quiz Cards
                                VStack(spacing: 15) { // Spacing between quiz cards
                                    // Using direct NavigationLink for simplicity as in your uncommented code
                                    NavigationLink(destination: QuizView(type: "PHQ-9")) {
                                        QuizCard(title: "PHQ-9", subtitle: "Depression Assessment", icon: "heart.text.square", cardColor: Color("navyBlue")) // Pass primaryBlue
                                    }
                                    .buttonStyle(.plain) // Ensure no default button styling
                                    
                                    NavigationLink(destination: QuizView(type: "GAD-7")) {
                                        QuizCard(title: "GAD-7", subtitle: "Anxiety Assessment", icon: "brain.head.profile", cardColor: Color("emeraldGreen")) // Pass emeraldGreen
                                    }
                                    .buttonStyle(.plain) // Ensure no default button styling
                                    
                                    // Use sheet for QuizHistory (as per original code)
                                    Button {
                                        showQuizHistory = true
                                    } label: {
                                        QuizCard(title: "Test History", subtitle: "See your history results", icon: "book.pages.fill", cardColor: Color("coralOrange")) // Pass coralOrange
                                    }
                                    .buttonStyle(.plain) // Ensure no default button styling
                                    .sheet(isPresented: $showQuizHistory) {
                                        QuizHistory()
                                    }
                                }
                                .padding(.horizontal, 20) // Apply horizontal padding to the card stack
                            }
                        }
                        
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    }
                }
            }
            .onChange(of: authVM.user?.uid ?? "", initial: true) { _, newUID in
                if !newUID.isEmpty {
                    Task {
                        do {
                            try await authVM.fetchUserProfile(userID: newUID)
                        } catch {
                            print("Error loading user: \(error)")
                        }
                    }
                }
            }
            // No specific navigationTitle or toolbar setup needed here unless you want a title in the window.
            // On macOS, the toolbar is often handled by the NavigationView itself or custom views.
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) { // Increased spacing
                Text("Hi \(authVM.myUser.name)")
                    .font(.largeTitle) // More prominent font
                    .fontWeight(.bold)
                    .foregroundColor(Color("navyBlue")) // Navy Blue for strong headings
                
                Text("Your journey matters.\nLet's see how you're growing.")
                    .font(.title3) // Clearer font size
                    .foregroundColor(Color("navyBlue")) // System secondary for adaptability
            }
            
            Spacer()
            
            // Assuming "Image1" is an asset that adapts to dark mode or is neutral.
            Image("Image1")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90) // Slightly larger image
                .clipShape(Circle()) // Clip to circle for a profile-like image
                .overlay(Circle().stroke(Color("navyBlue").opacity(0.5), lineWidth: 2)) // Subtle border
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2) // Gentle shadow
        }
        .padding(.top, 30) // More top padding
        .padding(.bottom, 20)
        .padding(.horizontal, 30) // More horizontal padding
    }
    
    private var freshStartSection: some View {
        VStack(spacing: 20) { // Increased spacing
            Text("Your Fresh Start")
                .font(.title) // Larger and bolder
                .fontWeight(.bold)
                .foregroundColor(Color("navyBlue")) // Navy Blue for heading
            
            Text("Welcome! Let's grow together, one day at a time.")
                .font(.body) // Standard body text
                .foregroundColor(Color("navyBlue")) // Adapts for dark/light mode
                .multilineTextAlignment(.center)
            
            // Graph Placeholder
            // Using Material for the placeholder background to adapt to dark mode
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("skyBlue")) 
                .frame(height: 200) // Taller placeholder
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50)) // Larger icon
                            .foregroundColor(.secondary) // Adapts
                        Text("Overall Progress Chart") // More descriptive text
                            .font(.title3) // Larger text
                            .fontWeight(.semibold)
                            .foregroundColor(Color("lightGray1")) // Adapts
                    }
                    
                )
                
        }
        .padding(.horizontal, 30) // Horizontal padding for this section
        .padding(.bottom, 30) // More bottom padding for separation
    }
}

// MARK: - Components

struct QuizCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let cardColor: Color // New parameter to pass the accent color

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 28)) // Larger icon
                .foregroundColor(.white) // Always white on the colored background
                .frame(width: 60, height: 60) // Larger frame
                .background(Color.white.opacity(0.2)) // Subtle translucent background
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) { // Increased spacing
                Text(title)
                    .font(.title2) // Larger and bolder title
                    .fontWeight(.semibold)
                    .foregroundColor(.white) // White text on the colored card
                
                Text(subtitle)
                    .font(.callout) // Clearer subtitle
                    .foregroundColor(Color.white.opacity(0.8)) // Slightly transparent white
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.white.opacity(0.7))
                .font(.title3) // Larger chevron
        }
        .padding(25) // More padding inside the card
        .frame(maxWidth: .infinity)
        // Removed fixed height, let content define height if needed, or set minHeight
        // .frame(minHeight: 120) // Can use minHeight instead of fixed height
        .background(cardColor) // Use the passed accent color for the card background
        .cornerRadius(20) // More rounded corners for softness
        .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4) // Adaptive shadow
    }
}




#Preview {
    HomeView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(QuizViewModel(type: "PHQ-9")) // Ensure QuizViewModel and HistoryViewModel are mocked/initialized for preview
        .environmentObject(HistoryViewModel())
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())
        .environment(\.colorScheme, .dark) // Dark mode preview
//        .previewDisplayName("HomeView - Dark Mode")
}
