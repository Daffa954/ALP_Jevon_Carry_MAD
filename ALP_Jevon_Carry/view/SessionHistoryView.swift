import SwiftUI

// Main view for displaying session history - macOS full screen optimized
struct SessionHistoryView: View {
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Custom header for macOS
                HStack {
                    Text("Breathing History")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .background(Color.white)
                
                // Main content area
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [Color.white, Color.gray.opacity(0.1)],
                        startPoint: .top, endPoint: .bottom
                    ).ignoresSafeArea()

                    // Main content based on state
                    if historyViewModel.isLoading {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView().scaleEffect(1.5).tint(Color.blue)
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
                                                .foregroundColor(Color.blue))
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
                        ScrollView {
                            LazyVStack(spacing: geometry.size.width > 1000 ? 28 : 24) {
                                ForEach(historyViewModel.groupedSessions) { groupData in
                                    // Session group card
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text(historyViewModel.formatSectionDateTitle(groupData.id))
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Text(historyViewModel.formatSessionCountText(groupData.sessions.count))
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.gray.opacity(0.2))
                                                .clipShape(Capsule())
                                        }
                                        
                                        // Responsive layout based on window width
                                        if geometry.size.width > 1000 {
                                            // Grid layout for wide screens
                                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: geometry.size.width > 1400 ? 3 : 2), spacing: 16) {
                                                ForEach(groupData.sessions) { session in
                                                    sessionRowView(session: session)
                                                }
                                            }
                                        } else {
                                            // Vertical stack for narrow screens
                                            VStack(spacing: 8) {
                                                ForEach(groupData.sessions) { session in
                                                    sessionRowView(session: session)
                                                }
                                            }
                                        }
                                    }
                                    .padding(geometry.size.width > 1000 ? 24 : 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.gray.opacity(0.1))
                                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                    )
                                }
                            }
                            .padding(.horizontal, geometry.size.width > 1000 ? 32 : 24)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                        .background(Color.clear)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    
    @ViewBuilder
    private func sessionRowView(session: BreathingSession) -> some View {
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
                        .foregroundColor(.primary)
                    Text("Duration: \(historyViewModel.formatSessionDuration(session.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            // macOS hover effect can be added here
        }
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
        let authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
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
