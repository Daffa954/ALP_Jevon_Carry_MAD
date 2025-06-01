//
//  JournalView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct JournalView: View {
    @State var isAdding: Bool = false
    @State var userId: String
    @EnvironmentObject var listJournalVM: ListJournalViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack{
            ZStack {
                // Enhanced background gradient
                LinearGradient(
                    colors: [Color("lightGray1"), Color("lightGray1").opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 25) {
                        
                        // Enhanced Header Section
                        VStack(spacing: 12) {
                            Text("My Journal")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(Color("navyBlue"))
                            
                            Text("Welcome back, \(authVM.myUser.name)!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(Color("navyBlue"))
                        }
                        .padding(.top, 10)
                        
                        // Enhanced Weekly Stress Chart Section
                        VStack(spacing: 18) {
                            VStack(spacing: 6) {
                                Text("Your Weekly Stress Level")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color("navyBlue"))
                                
                                Text("Insights from your journal entries")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color("navyBlue").opacity(0.8))
                            }
                            
                            // Enhanced Chart container
                            VStack {
                                JournalChartView(journalData: listJournalVM.allJournalThisWeek)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white)
                                    .shadow(color: Color("navyBlue").opacity(0.15), radius: 12, x: 0, y: 6)
                            )
                        }
                        .padding(.horizontal, 6)
                        
                        // Enhanced History Section
                        VStack(alignment: .leading, spacing: 18) {
                            HStack {
                                Text("Recent Entries")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color("navyBlue"))
                                
                                Spacer()
                                
                                if !listJournalVM.allJournalHistories.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color("emeraldGreen"))
                                        
                                        Text("\(listJournalVM.allJournalHistories.count) entries this week")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundStyle(Color("emeraldGreen"))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color("emeraldGreen").opacity(0.12))
                                    )
                                }
                            }
                            
                            // Enhanced Journal entries
                            LazyVStack(spacing: 14) {
                                if listJournalVM.allJournalThisWeek.isEmpty {
                                    // Enhanced Empty state
                                    VStack(spacing: 20) {
                                        ZStack {
                                            Circle()
                                                .fill(Color("skyBlue").opacity(0.1))
                                                .frame(width: 80, height: 80)
                                            
                                            Image(systemName: "book.closed")
                                                .font(.system(size: 32, weight: .medium))
                                                .foregroundColor(Color("skyBlue"))
                                        }
                                        
                                        VStack(spacing: 10) {
                                            Text("No entries yet")
                                                .font(.system(size: 20, weight: .semibold))
                                                .foregroundColor(Color("navyBlue"))
                                            
                                            Text("Start your journaling journey by tapping the + button")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color("navyBlue").opacity(0.8))
                                                .multilineTextAlignment(.center)
                                                .lineSpacing(2)
                                        }
                                    }
                                    .padding(.vertical, 45)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.white, Color.white.opacity(0.8)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(color: Color("navyBlue").opacity(0.06), radius: 8, x: 0, y: 4)
                                    )
                                } else {
                                    ForEach(listJournalVM.allJournalHistories, id: \.id) { journal in
                                        JournalCardView(journal: journal)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for floating button
                    }
                    .padding(.horizontal, 22)
                }
            }
            .toolbar {
                ToolbarItem() {
                    Button(action: {
                        isAdding = true
                    }) {
                        ZStack {
                            // Enhanced button design
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("coralOrange"), Color("coralOrange").opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .shadow(color: Color("coralOrange").opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .accessibilityIdentifier("addBookButton")
                }
            }
            
            .navigationDestination(isPresented: $isAdding, destination: {
                AddJournalView(isAddJournal: $isAdding, userID: userId)
            })
            .onChange(of: authVM.user?.uid ?? "", initial: true) { oldUID, newUID in
                if !newUID.isEmpty {
                    listJournalVM.fetchJournalThisWeek(userID: newUID)
                    listJournalVM.fetchAllJournal(userID: newUID)
                } else {
                    listJournalVM.allJournalThisWeek = []
                    listJournalVM.allJournalHistories = []
                }
            }
        }
    }
}



#Preview {
    JournalView(userId: "fBdMKF5GIvMuufer7JqzgPgVwEI2")
        .environmentObject(ListJournalViewModel())
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(JournalViewModel())
}
