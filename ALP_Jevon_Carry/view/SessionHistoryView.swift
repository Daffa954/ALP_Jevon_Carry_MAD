//
//  SessionHistoryView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//


// SessionHistoryView.swift (Create this new file)
// Make sure to import SwiftUI
// SessionHistoryView.swift
// Make sure to import SwiftUI
// SessionHistoryView.swift
import SwiftUI

struct SessionHistoryView: View {
    @StateObject var historyViewModel: SessionHistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private let viewBackgroundColor = Color.white
    private let primaryTextColor = AppColors.lightPrimaryText
    private let secondaryTextColor = AppColors.lightSecondaryText
    private let sectionHeaderColor = AppColors.accent
    private let listRowBackgroundColor = AppColors.lightSessionListRowBackground // e.g., Color.white or very light gray

    var body: some View {
        NavigationView {
            Group {
                if historyViewModel.isLoading {
                    VStack { Spacer(); ProgressView("Loading History...").foregroundColor(primaryTextColor); Spacer() }
                } else if let errorMessage = historyViewModel.errorMessage {
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill").resizable().scaledToFit().frame(width: 50, height: 50).foregroundColor(.orange)
                        Text("Error").font(.title).foregroundColor(primaryTextColor)
                        Text(errorMessage).font(.callout).foregroundColor(secondaryTextColor).multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") { historyViewModel.fetchSessionHistory() }.padding().buttonStyle(.borderedProminent).tint(AppColors.accent)
                        Spacer()
                    }.padding()
                } else if historyViewModel.datedSessionGroups.isEmpty {
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "moon.stars.fill").resizable().scaledToFit().frame(width: 80, height: 80).foregroundColor(AppColors.neutralColor)
                        Text("No Sessions Yet").font(.title2).foregroundColor(primaryTextColor)
                        Text("Complete a breathing session to see your history here.").font(.callout).foregroundColor(secondaryTextColor).multilineTextAlignment(.center).padding(.horizontal)
                        Spacer()
                    }.padding()
                } else {
                    List {
                        ForEach(historyViewModel.datedSessionGroups) { group in
                            Section(header:
                                Text(group.id, style: .date).font(.headline).foregroundColor(sectionHeaderColor)
                            ) {
                                ForEach(group.sessions) { session in
                                    SessionRow(
                                        session: session,
                                        primaryTextColor: primaryTextColor,
                                        secondaryTextColor: secondaryTextColor,
                                        iconColor: AppColors.inhaleColor
                                    )
                                }
                            }
                            .listRowBackground(listRowBackgroundColor)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.inline)
            .background(viewBackgroundColor.edgesIgnoringSafeArea(.all))
            .onAppear {
                historyViewModel.fetchSessionHistory()
            }
        }
        .accentColor(AppColors.accent)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SessionRow: View {
    let session: BreathingSession
    var primaryTextColor: Color
    var secondaryTextColor: Color
    var iconColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Time: \(session.sessionDate, style: .time)")
                    .font(.headline)
                    .foregroundColor(primaryTextColor)
                Text("Duration: \(formatDuration(session.duration))")
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
            }
            Spacer()
            Image(systemName: "leaf.fill")
                .foregroundColor(iconColor.opacity(0.7))
        }
        .padding(.vertical, 4)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewAuthVM = AuthViewModel()
        previewAuthVM.isSigneIn = true
        previewAuthVM.myUser = MyUser(
            uid: "previewUser123",
            name: "History Previewer",
            email: "history@example.com"
        )
            
        let historyVM = SessionHistoryViewModel(authViewModel: previewAuthVM)
        
        let sampleDate1 = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        let sampleDate2 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        
        historyVM.datedSessionGroups = [
            DatedSessionGroup(id: Calendar.current.startOfDay(for: sampleDate1), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: sampleDate1.addingTimeInterval(-3600), duration: 120),
                BreathingSession(userID: "previewUser123", sessionDate: sampleDate1.addingTimeInterval(-7200), duration: 300)
            ]),
            DatedSessionGroup(id: Calendar.current.startOfDay(for: sampleDate2), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: sampleDate2.addingTimeInterval(-3600), duration: 180)
            ])
        ]
        // historyVM.isLoading = false // Ensure not stuck for preview
        
        return SessionHistoryView(historyViewModel: historyVM)
            .environmentObject(previewAuthVM)
    }
}
