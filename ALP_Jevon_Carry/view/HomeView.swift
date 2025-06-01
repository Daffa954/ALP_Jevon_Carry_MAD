import SwiftUI

struct HomeView: View {
    @State private var selectedQuizType: String = ""
    let cornerRadius: CGFloat = 30
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showQuizPHQ = false
    @State private var showQuizGAD = false
    @State private var showQuizHistory = false
    
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
                                VStack(spacing: 10) {
                                    Text("Check Your Mental Health")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color("navyBlue"))
                                    
                                    Text("For best results, this test is limited to one session per week.")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.center)
                                }
                                
                                // Quiz Cards
                                //START COMMENT
//                                VStack(spacing: 15) {
//                                    NavigationLink(
//                                        destination: QuizView(type: "PHQ-9", tab: $tab)
//                                            .environmentObject(QuizViewModel(type: "PHQ-9"))
//                                            .environmentObject(HistoryViewModel()),
//                                        label: {
//                                            QuizCard(title: "PHQ-9",
//                                                     subtitle: "Depression Assessment",
//                                                     icon: "heart.text.square")
//                                        }
//                                    )
//                                    
//                                    NavigationLink(
//                                        destination: QuizView(type: "GAD-7", tab: $tab)
//                                            .environmentObject(QuizViewModel(type: "GAD-7"))
//                                            .environmentObject(HistoryViewModel()),
//                                        label: {
//                                            QuizCard(title: "GAD-7",
//                                                     subtitle: "Anxiety Assessment",
//                                                     icon: "brain.head.profile")
//                                        }
//                                    )
//                                }
                                //END COMMENT
                                
                                NavigationLink(destination: QuizView(type: "PHQ-9")){
                                    QuizCard(title: "PHQ-9", subtitle: "Depression Assessment", icon: "heart.text.square")
                                }
                                
                                NavigationLink(destination: QuizView(type: "GAD-7")){
                                    QuizCard(title: "GAD-7", subtitle: "Anxiety Assessment", icon: "brain.head.profile")
                                }
                                
//                                Button {
//                                    showQuizPHQ = true
//                                } label: {
//                                    QuizCard(title: "PHQ-9", subtitle: "Depression Assessment", icon: "heart.text.square")
//                                }
//                                .fullScreenCover(isPresented: $showQuizPHQ) {
//                                    QuizView(type: "PHQ-9", tab: $tab, isPresented: $showQuizPHQ)
//                                        .environmentObject(QuizViewModel(type: "PHQ-9"))
//                                        .environmentObject(HistoryViewModel())
//                                }
                                
//                                Button {
//                                    showQuizGAD = true
//                                } label: {
//                                    QuizCard(title: "GAD-7", subtitle: "Anxiety Assessment", icon: "brain.head.profile")
//                                }
//                                .fullScreenCover(isPresented: $showQuizGAD) {
//                                    QuizView(type: "GAD-7", tab: $tab, isPresented: $showQuizGAD)
//                                        .environmentObject(QuizViewModel(type: "GAD-7"))
//                                        .environmentObject(HistoryViewModel())
//                                }
                                
                                Button {
                                    showQuizHistory = true
                                } label: {
                                    QuizCard(title: "Test History", subtitle: "See your history results", icon: "book.pages.fill")
                                }
                                .sheet(isPresented: $showQuizHistory) {
                                    QuizHistory()
                                }
                                
                                
                                
                            }
                            
                        }
                        .padding(.horizontal, 35)
                        .padding(.bottom, 50) // Padding untuk Tab Bar
                        
                        .background(Color("color1").opacity(0.8))
                        .clipShape(RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight]))
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
    
    // MARK: - UI Components
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Hi \(authVM.myUser.name)")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color("navyBlue"))
                
                
                Text("Your journey matters.\nLet's see how you're growing.")
                    .font(.system(size: 16))
                    .foregroundColor(Color("navyBlue"))
            }
            
            Spacer()
            
            Image("Image1")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        }
        .padding(.top, 20)
        .padding(.bottom, 30)
        .padding(.horizontal, 25)
        
        
    }
    
    private var freshStartSection: some View {
        VStack(spacing: 15) {
            Text("Your Fresh Start")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("navyBlue"))
            
            Text("Welcome! Let's grow together,\none day at a time.")
                .font(.system(size: 18))
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
            
            // Graph Placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .frame(height: 180)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Overall Graph")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                )
        }
        .padding(.top, 25)
    }
    
    
}

// MARK: - Components

struct QuizCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.white.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(subtitle)
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
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())
}
