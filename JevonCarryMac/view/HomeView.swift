import SwiftUI

struct HomeView: View {
    @State private var selectedQuizType: String = ""
    let cornerRadius: CGFloat = 30
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        headerSection
                        
                        // Main Content
                        VStack(spacing: 25) {
                            // Fresh Start Section
                            freshStartSection
                            
                            // Quiz Cards Section
                            VStack(spacing: 20) {
                                VStack(spacing: 12) {
                                    Text("Check Your Mental Health")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(Color("navyBlue"))
                                    
                                    Text("For best results, this test is limited to one session per week.")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color("navyBlue").opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 10)
                                }
                                
                                // Quiz Cards
                                VStack(spacing: 16) {
                                    NavigationLink(
                                        destination: QuizView(type: "PHQ-9")
                                            .environmentObject(QuizViewModel(type: "PHQ-9"))
                                            .environmentObject(HistoryViewModel()),
                                        label: {
                                            QuizCard(title: "PHQ-9",
                                                     subtitle: "Depression Assessment",
                                                     icon: "heart.text.square",
                                                     gradientColors: [Color("skyBlue"), Color("skyBlue").opacity(0.8)])
                                        }
                                    )
                                    
                                    NavigationLink(
                                        destination: QuizView(type: "GAD-7")
                                            .environmentObject(QuizViewModel(type: "GAD-7"))
                                            .environmentObject(HistoryViewModel()),
                                        label: {
                                            QuizCard(title: "GAD-7",
                                                     subtitle: "Anxiety Assessment",
                                                     icon: "brain.head.profile",
                                                     gradientColors: [Color("coralOrange"), Color("coralOrange").opacity(0.8)])
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 35)
                        .padding(.bottom, 50)
                        .background(Color("lightGray1"))
                    }
                }
            }
            .background(Color("lightGray1"))
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
        }
    }
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Hi \(authVM.myUser.name)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color("navyBlue"))
                
                Text("Your journey matters.\nLet's see how you're growing.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("navyBlue").opacity(0.8))
                    .lineSpacing(2)
            }
            
            Spacer()
            
            Image("Image1")
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .background(
                    Circle()
                        .fill(Color("skyBlue").opacity(0.1))
                        .frame(width: 95, height: 95)
                )
        }
        .padding(.top, 25)
        .padding(.bottom, 35)
        .padding(.horizontal, 30)
        .background(Color("lightGray1"))
    }
    
    private var freshStartSection: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("Your Fresh Start")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color("lightGray1"))
                
                Text("Welcome! Let's grow together,\none day at a time.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color("navyBlue").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            
            // Enhanced Graph Placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color("lightGray1").opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 190)
                .overlay(
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color("skyBlue").opacity(0.1))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(Color("skyBlue"))
                        }
                        
                        VStack(spacing: 4) {
                            Text("Overall Progress")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color("navyBlue"))
                            
                            Text("Track your mental health journey")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("skyBlue").opacity(0.6))
                        }
                    }
                )
                .shadow(color: Color("navyBlue").opacity(0.08), radius: 8, x: 0, y: 4)
        }
        .padding(.top, 30)
    }
}

// MARK: - Enhanced Components

struct QuizCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradientColors: [Color]
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 55, height: 55)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            // Arrow
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 35, height: 35)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(18)
        .shadow(color: gradientColors.first?.opacity(0.3) ?? Color.clear, radius: 8, x: 0, y: 4)
    }
}

// MARK: - App Colors




#Preview {
    HomeView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(QuizViewModel(type: "PHQ-9"))
}
