import SwiftUI

struct SessionHistoryView: View {
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top, endPoint: .bottom
                ).ignoresSafeArea()

                switch historyViewModel.viewState {
                case .loading:
                    LoadingView()
                case .error(let message):
                    ErrorView(message: message, viewModel: historyViewModel)
                case .empty:
                    EmptyStateView()
                case .loaded(let groups):
                    LoadedStateView(groups: groups)
                }
            }
            .navigationTitle("Breathing History")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await historyViewModel.fetchSessionHistory()
            }
            .onAppear {
                print("SessionHistoryView appeared. Current ViewModel state: \(historyViewModel.viewState.description)")
                // Instead of checking for a Firebase handle, use an isListening flag or similar
                if !historyViewModel.isPreviewMode &&
                    historyViewModel.getActiveUserID() != nil &&
                    !historyViewModel.isListening {
                    print("SessionHistoryView onAppear: Not listening and user is active. Attempting to set up listener.")
                    historyViewModel.setupFirebaseListener()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct LoadingView: View {
        var body: some View {
            VStack(spacing: 20) {
                ProgressView().scaleEffect(1.5).tint(Color("AccentColor"))
                Text("Loading your sessions...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    struct ErrorView: View {
        let message: String
        // Pass as plain property, not @ObservedObject, as parent owns the view model
        var viewModel: SessionHistoryViewModel
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50)).foregroundColor(.orange)
                VStack(spacing: 8) {
                    Text("Something went wrong").font(.title2).fontWeight(.semibold)
                    Text(message)
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Button("Try Again") {
                    Task { await viewModel.fetchSessionHistory() }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    struct EmptyStateView: View {
        var body: some View {
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
        }
    }

    struct LoadedStateView: View {
        let groups: [DatedSessionGroupDisplayData]

        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(groups) { groupData in
                            SessionGroupCardView(groupDisplayData: groupData, onSessionTap: { sessionDisplayData in
                                print("Session tapped: \(sessionDisplayData.id) at \(sessionDisplayData.timeText)")
                                // Add navigation or sheet presentation logic here if needed
                            })
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    struct SessionGroupCardView: View {
        let groupDisplayData: DatedSessionGroupDisplayData
        let onSessionTap: (BreathingSessionDisplayData) -> Void
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(groupDisplayData.formattedDateTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.black)
                    Spacer()
                    Text(groupDisplayData.sessionCountText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
                VStack(spacing: 8) {
                    ForEach(groupDisplayData.sessions) { sessionData in
                        SessionRowCardView(sessionDisplayData: sessionData, onTap: { onSessionTap(sessionData) })
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

    struct SessionRowCardView: View {
        let sessionDisplayData: BreathingSessionDisplayData
        let onTap: () -> Void
        var body: some View {
            Button(action: onTap) {
                HStack(spacing: 16) {
                    Circle()
                        .fill(LinearGradient(colors: [Color("color1"), Color("coralOrange")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .overlay(Image(systemName: "leaf.fill").font(.system(size: 18)).foregroundColor(.white))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sessionDisplayData.timeText)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.black)
                        Text("Duration: \(sessionDisplayData.durationText)")
                            .font(.subheadline)
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .medium)).foregroundColor(Color.gray)
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

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        }
    }
}

// MARK: - Placeholder/Definitions for previously "out of scope" Views
struct DetailRow: View {
    let title: String
    let value: String
    var body: some View {
        HStack {
            Text(title).font(.callout).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.callout).fontWeight(.medium)
        }.padding(.vertical, 4)
    }
}

struct SessionDetailView: View { // Assuming BreathingSession is your model
    let session: BreathingSession
    @Environment(\.dismiss) private var dismiss
    private func formatDetailDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration); let minutes = totalSeconds / 60; let seconds = totalSeconds % 60
        if minutes > 0 && seconds > 0 { return "\(minutes) minutes, \(seconds) seconds" }
        if minutes > 0 { return "\(minutes) minute\(minutes == 1 ? "" : "s")" }
        return "\(seconds) second\(seconds == 1 ? "" : "s")"
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "leaf.fill").font(.system(size: 50)).foregroundColor(Color("AccentColor")).padding(.bottom, 20)
                DetailRow(title: "Date", value: session.sessionDate.formatted(date: .long, time: .omitted))
                DetailRow(title: "Time", value: session.sessionDate.formatted(date: .omitted, time: .shortened))
                DetailRow(title: "Duration", value: formatDetailDuration(session.duration))
                Spacer()
            }.padding().navigationTitle("Session Details").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

// MARK: - Preview Provider (Your Original Version)
struct SessionHistoryView_Previews: PreviewProvider {
    static func createSampleSessions() -> [BreathingSession] {
        let today = Date(); let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        return [
            BreathingSession(id: "s1",userID: "previewUser", sessionDate: today.addingTimeInterval(-1*60*15), duration: 300),
            BreathingSession(id: "s2",userID: "previewUser", sessionDate: today.addingTimeInterval(-2*60*60), duration: 600),
            BreathingSession(id: "s3",userID: "previewUser", sessionDate: yesterday.addingTimeInterval(-3*60*60), duration: 420),
            BreathingSession(id: "s4",userID: "previewUser", sessionDate: twoDaysAgo.addingTimeInterval(-5*60*60), duration: 180)
        ]
    }

    static var previews: some View {
        let authViewModel = AuthViewModel() // AuthViewModel must be defined
        if authViewModel.myUser.uid.isEmpty {
            authViewModel.myUser = MyUser(uid: "previewUser123", name: "Preview User", email: "preview@example.com")
            authViewModel.isSigneIn = true
        }

        let loadingVM = SessionHistoryViewModel(authViewModel: authViewModel)
        loadingVM.configureForPreview(state: HistoryViewState.loading)

        let emptyVM = SessionHistoryViewModel(authViewModel: authViewModel)
        emptyVM.setupPreviewData(sampleSessions: [])

        let errorVM = SessionHistoryViewModel(authViewModel: authViewModel)
        errorVM.configureForPreview(state: HistoryViewState.error(message: "Network connection lost."))

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

            SessionHistoryView(historyViewModel: errorVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Error")

            SessionHistoryView(historyViewModel: loadedVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded (White BG)")

            SessionHistoryView(historyViewModel: loadedSingleVM)
                .environmentObject(authViewModel)
                .previewDisplayName("Loaded (Single - White BG)")
        }
    }
}
