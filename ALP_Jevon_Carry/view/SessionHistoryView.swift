//
//  SessionHistoryView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// SessionHistoryView.swift
import SwiftUI

struct SessionHistoryView: View {
    // MARK: - State Objects and Environment Objects
    @StateObject var historyViewModel: SessionHistoryViewModel // Your actual ViewModel
    @EnvironmentObject var authViewModel: AuthViewModel       // Your actual ViewModel

    // Define colors suitable for a white background, using your project's AppColors
    private let viewBackgroundColor = Color.white
    private let primaryTextColor = AppColors.lightPrimaryText
    private let secondaryTextColor = AppColors.lightSecondaryText
    private let sectionHeaderColor = AppColors.accent
    private let listRowBackgroundColor = AppColors.lightSessionListRowBackground

    // MARK: - Date Formatter for Section Headers
    private static let sectionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy" // Or your preferred format: "MMMM d, yyyy", etc.
        // formatter.locale = Locale(identifier: "en_US_POSIX") // For fixed format consistency
        return formatter
    }()

    private func formattedSectionDate(_ date: Date) -> String {
        return Self.sectionDateFormatter.string(from: date)
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            Group {
                if historyViewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Loading History...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .foregroundColor(primaryTextColor)
                        Spacer()
                    }
                } else if let errorMessage = historyViewModel.errorMessage {
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable().scaledToFit().frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        Text("Error").font(.title).foregroundColor(primaryTextColor)
                        Text(errorMessage).font(.callout).foregroundColor(secondaryTextColor)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Button("Retry") { historyViewModel.fetchSessionHistory() }
                            .padding().buttonStyle(.borderedProminent).tint(AppColors.accent)
                        Spacer()
                    }.padding()
                } else if historyViewModel.datedSessionGroups.isEmpty {
                    VStack(spacing: 15) {
                        Spacer()
                        Image(systemName: "moon.stars.fill")
                            .resizable().scaledToFit().frame(width: 80, height: 80)
                            .foregroundColor(AppColors.neutralColor)
                        Text("No Sessions Yet").font(.title2).foregroundColor(primaryTextColor)
                        Text("Complete a breathing session to see your history here.")
                            .font(.callout).foregroundColor(secondaryTextColor)
                            .multilineTextAlignment(.center).padding(.horizontal)
                        Spacer()
                    }.padding()
                } else {
                    List {
                        ForEach(historyViewModel.datedSessionGroups) { group in
                            Section(header:
                                Text(formattedSectionDate(group.id)) // Uses custom date format
                                    .font(.headline)
                                    .foregroundColor(sectionHeaderColor)
                                    .padding(.vertical, 5)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                            .listRowBackground(listRowBackgroundColor)
                        }
                    }
                    .listStyle(PlainListStyle()) // Or InsetGroupedListStyle
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
    let session: BreathingSession // From your project's model folder

    var primaryTextColor: Color
    var secondaryTextColor: Color
    var iconColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
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
        .padding(.vertical, 8)
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

// MARK: - Preview
struct SessionHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        // Use your actual AuthViewModel and SessionHistoryViewModel from your project
        let previewAuthVM = AuthViewModel() // From your 'viewmodel' folder
        previewAuthVM.isSigneIn = true      // Using original property name
        previewAuthVM.myUser = MyUser(uid: "previewUser123", name: "Preview User", email: "preview@example.com") // MyUser from 'model' folder
            
        let historyVM = SessionHistoryViewModel(authViewModel: previewAuthVM) // SessionHistoryViewModel from 'viewmodel' folder
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let specificDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 21))!
        
        // Use DatedSessionGroup and BreathingSession from your project's 'model' folder
        // (or wherever DatedSessionGroup is defined - usually with SessionHistoryViewModel)
        historyVM.datedSessionGroups = [
            DatedSessionGroup(id: Calendar.current.startOfDay(for: specificDate), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: specificDate.addingTimeInterval(-1*60*60), duration: 120),
            ]),
            DatedSessionGroup(id: Calendar.current.startOfDay(for: today), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: today.addingTimeInterval(-1*60*60), duration: 12),
                BreathingSession(userID: "previewUser123", sessionDate: today.addingTimeInterval(-1*60*60 - 1*60), duration: 1),
            ]),
            DatedSessionGroup(id: Calendar.current.startOfDay(for: yesterday), sessions: [
                BreathingSession(userID: "previewUser123", sessionDate: yesterday.addingTimeInterval(-3*60*60), duration: 180),
            ])
        ]
        historyVM.isLoading = false
        
        return SessionHistoryView(historyViewModel: historyVM)
            .environmentObject(previewAuthVM)
            // For AppColors to work in preview, ensure your AppColors.swift is part of the target
            // and the color assets exist.
    }
}
