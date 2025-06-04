import SwiftUI

struct SessionHistoryView: View {
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showingSessionHistory: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with Back button
                HStack {
                    Button(action: {
                        showingSessionHistory = false
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("skyBlue"))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("skyBlue"))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                    Text("Breathing History")
                        .font(.system(size: 32, weight: .thin, design: .rounded))
                        .foregroundColor(.black)
                    Spacer()
                    Spacer().frame(width: 80) // to balance the back button space
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 16)
                .background(Color.white)
                .overlay(
                    Divider().offset(y: 16),
                    alignment: .bottom
                )

                // Content
                ZStack {
                    // Light background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white, Color("skyBlue").opacity(0.05), Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    if historyViewModel.isLoading {
                        VStack(spacing: 24) {
                            ProgressView().scaleEffect(1.5).tint(Color("skyBlue"))
                            Text("Loading your sessions...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if historyViewModel.isEmpty {
                        VStack(spacing: 24) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("color1").opacity(0.25), Color("coralOrange").opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .overlay(
                                    Image(systemName: "wind")
                                        .font(.system(size: 44))
                                        .foregroundColor(Color("skyBlue"))
                                )

                            Text("No Sessions Yet")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                            Text("Start your breathing journey today!\nYour completed sessions will appear here.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 100)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: geometry.size.width > 1100 ? 32 : 24) {
                                ForEach(historyViewModel.groupedSessions) { groupData in
                                    VStack(alignment: .leading, spacing: 18) {
                                        // Section date header
                                        HStack {
                                            Text(historyViewModel.formatSectionDateTitle(groupData.id))
                                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                                .foregroundColor(.black)
                                            Spacer()
                                            Text(historyViewModel.formatSessionCountText(groupData.sessions.count))
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.black.opacity(0.7)) // Dark elegant
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color("skyBlue").opacity(0.07))
                                                .clipShape(Capsule())
                                        }

                                        // Cards grid or list
                                        if geometry.size.width > 1000 {
                                            LazyVGrid(
                                                columns: Array(
                                                    repeating: GridItem(.flexible(), spacing: 18),
                                                    count: geometry.size.width > 1600 ? 3 : 2
                                                ),
                                                spacing: 18
                                            ) {
                                                ForEach(groupData.sessions) { session in
                                                    SessionHistoryRow(session: session, historyViewModel: historyViewModel)
                                                }
                                            }
                                        } else {
                                            VStack(spacing: 10) {
                                                ForEach(groupData.sessions) { session in
                                                    SessionHistoryRow(session: session, historyViewModel: historyViewModel)
                                                }
                                            }
                                        }
                                    }
                                    .padding(geometry.size.width > 1000 ? 32 : 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(Color.white)
                                            .shadow(color: Color("skyBlue").opacity(0.06), radius: 8, x: 0, y: 2)
                                    )
                                }
                            }
                            .padding(.horizontal, geometry.size.width > 1000 ? 60 : 32)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                        .background(Color.clear)
                    }
                }
            }
        }
        .frame(minWidth: 900, minHeight: 700)
        .refreshable {
            historyViewModel.fetchSessionHistory()
        }
        .onAppear {
            if !historyViewModel.isPreviewMode &&
                historyViewModel.getActiveUserID() != nil &&
                !historyViewModel.isListening {
                historyViewModel.setupFirebaseListener()
            }
        }
    }
}

struct SessionHistoryRow: View {
    let session: BreathingSession
    let historyViewModel: SessionHistoryViewModel

    var body: some View {
        HStack(spacing: 18) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("color1"), Color("coralOrange")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(historyViewModel.formatSessionTime(session.sessionDate))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.black)
                Text("Duration: \(historyViewModel.formatSessionDuration(session.duration))")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.black.opacity(0.7)) // Dark elegant
            }

            Spacer()
            // Arrow removed for a cleaner look
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color("skyBlue").opacity(0.04), radius: 3, x: 0, y: 1)
        )
        .buttonStyle(PlainButtonStyle())
        .onHover { isHovered in
            // Optionally add hover effect if desired
        }
    }
}

// MARK: - Preview Provider
struct SessionHistoryView_Previews: PreviewProvider {
    static func createSampleSessions() -> [BreathingSession] {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!

        return [
            BreathingSession(id: "s1", userID: "previewUser", sessionDate: today.addingTimeInterval(-1*60*15), duration: 300),
            BreathingSession(id: "s2", userID: "previewUser", sessionDate: today.addingTimeInterval(-2*60*60), duration: 600),
            BreathingSession(id: "s3", userID: "previewUser", sessionDate: yesterday.addingTimeInterval(-3*60*60), duration: 420),
            BreathingSession(id: "s4", userID: "previewUser", sessionDate: twoDaysAgo.addingTimeInterval(-5*60*60), duration: 180)
        ]
    }

    static var previews: some View {
        let authViewModel = AuthViewModel(repository: FirebaseAuthRepository())
        if authViewModel.myUser.uid.isEmpty {
            authViewModel.myUser = MyUser(uid: "previewUser123", name: "Preview User", email: "preview@example.com")
            authViewModel.isSigneIn = true
        }

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
            SessionHistoryView(historyViewModel: loadingVM, showingSessionHistory: .constant(true))
                .environmentObject(authViewModel)
                .previewDisplayName("Loading")

            SessionHistoryView(historyViewModel: emptyVM, showingSessionHistory: .constant(true))
                .environmentObject(authViewModel)
                .previewDisplayName("Empty")

            SessionHistoryView(historyViewModel: loadedVM, showingSessionHistory: .constant(true))
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded")

            SessionHistoryView(historyViewModel: loadedSingleVM, showingSessionHistory: .constant(true))
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded Single")
        }
    }
}
