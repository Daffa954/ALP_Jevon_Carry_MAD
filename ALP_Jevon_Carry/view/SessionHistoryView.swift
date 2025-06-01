import SwiftUI

// Main view for displaying session history
struct SessionHistoryView: View {
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                // Main content based on state
                if historyViewModel.isLoading {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView().scaleEffect(1.5).tint(Color("AccentColor"))
                        Text("Loading your sessions...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if historyViewModel.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [Color("color1").opacity(0.3), Color("coralOrange").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                                .overlay(Image(systemName: "wind")
                                            .font(.system(size: 40))
                                            .foregroundColor(Color("AccentColor")))
                            VStack(spacing: 8) {
                                Text("No Sessions Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Start your breathing journey today!\nYour completed sessions will appear here.")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Loaded state with sessions
                    ZStack {
                        Color.white.ignoresSafeArea()
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(historyViewModel.groupedSessions) { groupData in
                                    // Session group card
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text(historyViewModel.formatSectionDateTitle(groupData.id))
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color.black)
                                            Spacer()
                                            Text(historyViewModel.formatSessionCountText(groupData.sessions.count))
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.gray)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color(.systemGray5))
                                                .clipShape(Capsule())
                                        }
                                        
                                        VStack(spacing: 8) {
                                            ForEach(groupData.sessions) { session in
                                                // Individual session row
                                                Button(action: {
                                                    // Handle session tap if needed
                                                }) {
                                                    HStack(spacing: 16) {
                                                        Circle()
                                                            .fill(LinearGradient(colors: [Color("color1"), Color("coralOrange")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                            .frame(width: 44, height: 44)
                                                            .overlay(Image(systemName: "leaf.fill").font(.system(size: 18)).foregroundColor(.white))
                                                        
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(historyViewModel.formatSessionTime(session.sessionDate))
                                                                .font(.headline)
                                                                .fontWeight(.medium)
                                                                .foregroundColor(Color.black)
                                                            Text("Duration: \(historyViewModel.formatSessionDuration(session.duration))")
                                                                .font(.subheadline)
                                                                .foregroundColor(Color.gray)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "chevron.right")
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(Color.gray)
                                                    }
                                                    .padding(16)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color.white)
                                                    )
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                    .padding(20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemGray6))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Breathing History")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                historyViewModel.fetchSessionHistory()
            }
            .onAppear {
                // Setup Firebase listener when view appears
                if !historyViewModel.isPreviewMode &&
                    historyViewModel.getActiveUserID() != nil &&
                    !historyViewModel.isListening {
                    historyViewModel.setupFirebaseListener()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// MARK: - Preview Provider
struct SessionHistoryView_Previews: PreviewProvider {
    // Create sample sessions for preview
    static func createSampleSessions() -> [BreathingSession] {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        return [
            BreathingSession(id: "s1",userID: "previewUser", sessionDate: today.addingTimeInterval(-1*60*15), duration: 300),
            BreathingSession(id: "s2",userID: "previewUser", sessionDate: today.addingTimeInterval(-2*60*60), duration: 600),
            BreathingSession(id: "s3",userID: "previewUser", sessionDate: yesterday.addingTimeInterval(-3*60*60), duration: 420),
            BreathingSession(id: "s4",userID: "previewUser", sessionDate: twoDaysAgo.addingTimeInterval(-5*60*60), duration: 180)
        ]
    }

    static var previews: some View {
        // Setup preview authentication
        let authViewModel = AuthViewModel()
        if authViewModel.myUser.uid.isEmpty {
            authViewModel.myUser = MyUser(uid: "previewUser123", name: "Preview User", email: "preview@example.com")
            authViewModel.isSigneIn = true
        }

        // Create different preview states
        let loadingVM = SessionHistoryViewModel(authViewModel: authViewModel)
        loadingVM.configureForPreview(isLoading: true)

        let emptyVM = SessionHistoryViewModel(authViewModel: authViewModel)
        emptyVM.setupPreviewData(sampleSessions: [])

        let loadedVM = SessionHistoryViewModel(authViewModel: authViewModel)
        loadedVM.setupPreviewData(sampleSessions: createSampleSessions())
        
        let loadedSingleVM = SessionHistoryViewModel(authViewModel: authViewModel)
        loadedSingleVM.setupPreviewData(sampleSessions: [
            BreathingSession(id: "s5", userID: "previewUser", sessionDate: Date().addingTimeInterval(-30*60), duration: 120)
        ])

        return Group {
            SessionHistoryView(historyViewModel: loadingVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Loading")

            SessionHistoryView(historyViewModel: emptyVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Empty")

            SessionHistoryView(historyViewModel: loadedVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded")

            SessionHistoryView(historyViewModel: loadedSingleVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded Single")
        }
    }
}
