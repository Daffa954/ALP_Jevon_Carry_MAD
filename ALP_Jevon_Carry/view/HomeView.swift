import SwiftUI

struct HomeView: View {
    @State private var selectedQuizType: String = ""
    let cornerRadius: CGFloat = 35
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showQuizPHQ = false
    @State private var showQuizGAD = false
    @State private var showQuizHistory = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("skyBlue").opacity(0.3),
                        Color("color1").opacity(0.5),
                        Color("emeraldGreen").opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Elegant Header Section
                        VStack(spacing: 20) {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Hi \(authVM.myUser.name)")
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [Color("navyBlue"), Color("skyBlue")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("Your journey matters.\nLet's see how you're growing.")
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(Color("navyBlue").opacity(0.8))
                                        .lineSpacing(2)
                                }
                                
                                Spacer()
                                
                                // Elegant image with shadow and border
                                Image("Image1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 85, height: 85)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color("emeraldGreen"), Color("skyBlue")],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 3
                                            )
                                    )
                                    .shadow(color: Color("navyBlue").opacity(0.2), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        }
                        
                        // Main Content Card
                        VStack(spacing: 30) {
                            // Fresh Start Section - More elegant
                            VStack(spacing: 18) {
                                Text("Your Fresh Start")
                                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("navyBlue"))
                                
                                Text("Welcome! Let's grow together,\none day at a time.")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.95))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(3)
                                
                                // Elegant image container
                                Image("jevoncare")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: .infinity, maxHeight: 180)
                                    .clipped()
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            .padding(.top, 30)
                            
                            // Mental Health Check Section
                            VStack(spacing: 25) {
                                VStack(spacing: 12) {
                                    Text("Check Your Mental Health")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("navyBlue"))
                                    
                                    Text("For best results, this test is limited to one session per week.")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.9))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(2)
                                }
                                
                                // Quiz Cards inline design
                                VStack(spacing: 16) {
                                    // PHQ-9 Card
                                    NavigationLink(destination: QuizView(type: "PHQ-9")) {
                                        HStack {
                                            Image(systemName: "heart.text.square")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 50)
                                                .background(Color.white.opacity(0.2))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("PHQ-9")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("Depression Assessment")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 120)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    // GAD-7 Card
                                    NavigationLink(destination: QuizView(type: "GAD-7")) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 50)
                                                .background(Color.white.opacity(0.2))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("GAD-7")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("Anxiety Assessment")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 120)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    
                                    // Test History Button
                                    Button {
                                        showQuizHistory = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "book.pages.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                                .frame(width: 50, height: 50)
                                                .background(Color.white.opacity(0.2))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Test History")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(.white)
                                                
                                                Text("See your history results")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 120)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(15)
                                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    }
                                    .sheet(isPresented: $showQuizHistory) {
                                        QuizHistory()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 35)
                        .background(
                            // Elegant glass morphism effect
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color("color1").opacity(0.85),
                                            Color("color1").opacity(0.95)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.top, 25)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
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
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())
}
