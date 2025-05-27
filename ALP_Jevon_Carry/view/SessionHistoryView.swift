//
//  SessionHistoryView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// SessionHistoryView.swift
//
//  SessionHistoryView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

//
//  SessionHistoryView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct SessionHistoryView: View {
    // MARK: - State Objects and Environment Objects
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedSession: BreathingSession?
    @State private var showingSessionDetail = false

    // MARK: - Visual Constants
    private let cardCornerRadius: CGFloat = 16
    private let cardShadowRadius: CGFloat = 8
    private let sectionSpacing: CGFloat = 24
    private let rowSpacing: CGFloat = 12

    // MARK: - Date Formatters
    private static let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
    
    private static let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    private func formattedSectionDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            return Self.sectionDateFormatter.string(from: date)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemGray6).opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                contentView
            }
            .navigationTitle("Breathing History")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await refreshData()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingSessionDetail) {
            if let session = selectedSession {
                SessionDetailView(session: session)
            }
        }
    }
    
    // MARK: - Content Views
    @ViewBuilder
    private var contentView: some View {
        if historyViewModel.isLoading {
            loadingView
        } else if let errorMessage = historyViewModel.errorMessage {
            errorView(message: errorMessage)
        } else if historyViewModel.datedSessionGroups.isEmpty {
            emptyStateView
        } else {
            sessionListView
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppColors.accent)
            
            Text("Loading your sessions...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Try Again") {
                historyViewModel.fetchSessionHistory()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.inhaleColor.opacity(0.3), AppColors.exhaleColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "wind")
                            .font(.system(size: 40))
                            .foregroundColor(AppColors.accent)
                    )
                
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
    
    private var sessionListView: some View {
        ScrollView {
            LazyVStack(spacing: sectionSpacing) {
                ForEach(historyViewModel.datedSessionGroups) { group in
                    SessionGroupCard(
                        group: group,
                        dateTitle: formattedSectionDate(group.id),
                        onSessionTap: { session in
                            selectedSession = session
                            showingSessionDetail = true
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .onAppear {
            historyViewModel.fetchSessionHistory()
        }
    }
    
    // MARK: - Helper Methods
    @MainActor
    private func refreshData() async {
        historyViewModel.fetchSessionHistory()
        // Add a small delay for smooth refresh animation
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Session Group Card
struct SessionGroupCard: View {
    let group: DatedSessionGroup
    let dateTitle: String
    let onSessionTap: (BreathingSession) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date Header
            HStack {
                Text(dateTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(group.sessions.count) session\(group.sessions.count == 1 ? "" : "s")")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
            
            // Sessions
            VStack(spacing: 8) {
                ForEach(group.sessions) { session in
                    SessionRowCard(session: session) {
                        onSessionTap(session)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Session Row Card
struct SessionRowCard: View {
    let session: BreathingSession
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.inhaleColor, AppColors.exhaleColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    )
                
                // Session Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sessionDate, style: .time)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Duration: \(formatDuration(session.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.lightSecondaryText)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Session Detail View
struct SessionDetailView: View {
    let session: BreathingSession
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header Icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.inhaleColor, AppColors.exhaleColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    )
                
                VStack(spacing: 16) {
                    Text("Breathing Session")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        DetailRow(
                            title: "Date",
                            value: session.sessionDate.formatted(date: .abbreviated, time: .omitted)
                        )
                        
                        DetailRow(
                            title: "Time",
                            value: session.sessionDate.formatted(date: .omitted, time: .shortened)
                        )
                        
                        DetailRow(
                            title: "Duration",
                            value: formatDuration(session.duration)
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Session Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes) minutes \(seconds) seconds"
        } else if minutes > 0 {
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            return "\(seconds) second\(seconds == 1 ? "" : "s")"
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.accent)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewAuthVM = AuthViewModel()
        previewAuthVM.isSigneIn = true
        previewAuthVM.myUser = MyUser(uid: "previewUser123", name: "Preview User", email: "preview@example.com")
        
        let historyVM = SessionHistoryViewModel(authViewModel: previewAuthVM)
        historyVM.isPreviewMode = true
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: today)!
        
        // Set up dummy data for preview
        historyVM.datedSessionGroups = [
            // Today - Multiple sessions
            DatedSessionGroup(id: Calendar.current.startOfDay(for: today), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: today.addingTimeInterval(-1*60*60), duration: 420), // 7m
                BreathingSession(userID: "previewUser123", sessionDate: today.addingTimeInterval(-3*60*60), duration: 300), // 5m
                BreathingSession(userID: "previewUser123", sessionDate: today.addingTimeInterval(-8*60*60), duration: 180), // 3m
            ]),
            // Yesterday - Single longer session
            DatedSessionGroup(id: Calendar.current.startOfDay(for: yesterday), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: yesterday.addingTimeInterval(-2*60*60), duration: 600), // 10m
            ]),
            // Two days ago - Multiple varied sessions
            DatedSessionGroup(id: Calendar.current.startOfDay(for: twoDaysAgo), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: twoDaysAgo.addingTimeInterval(-1*60*60), duration: 480), // 8m
                BreathingSession(userID: "previewUser123", sessionDate: twoDaysAgo.addingTimeInterval(-4*60*60), duration: 240), // 4m
                BreathingSession(userID: "previewUser123", sessionDate: twoDaysAgo.addingTimeInterval(-7*60*60), duration: 120), // 2m
            ]),
            // Three days ago - Morning and evening sessions
            DatedSessionGroup(id: Calendar.current.startOfDay(for: threeDaysAgo), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: threeDaysAgo.addingTimeInterval(-2*60*60), duration: 900), // 15m
                BreathingSession(userID: "previewUser123", sessionDate: threeDaysAgo.addingTimeInterval(-10*60*60), duration: 360), // 6m
            ]),
            // One week ago - Single session
            DatedSessionGroup(id: Calendar.current.startOfDay(for: oneWeekAgo), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: oneWeekAgo.addingTimeInterval(-5*60*60), duration: 540), // 9m
            ]),
            // Two weeks ago - Quick sessions
            DatedSessionGroup(id: Calendar.current.startOfDay(for: twoWeeksAgo), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: twoWeeksAgo.addingTimeInterval(-3*60*60), duration: 90), // 1m 30s
                BreathingSession(userID: "previewUser123", sessionDate: twoWeeksAgo.addingTimeInterval(-6*60*60), duration: 150), // 2m 30s
                BreathingSession(userID: "previewUser123", sessionDate: twoWeeksAgo.addingTimeInterval(-9*60*60), duration: 75), // 1m 15s
            ])
        ]
        
        // Ensure we're not in loading state for preview
        historyVM.isLoading = false
        historyVM.errorMessage = nil
        
        return SessionHistoryView(historyViewModel: historyVM)
            .environmentObject(previewAuthVM)
    }
}
