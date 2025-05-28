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
                // Background gradient
                LinearGradient(
                    colors: [Color("lightGray1"), Color("lightGray1").opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 20) {
                        
                        // Header Section
                        VStack(spacing: 8) {
                            Text("My Journal")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color( "navyBlue"))
                            
                            Text("Welcome back, \(authVM.user?.displayName ?? "User")!")
                                .font(.subheadline)
                                .foregroundStyle(Color( "skyBlue"))
                        }
                        
                        
                        // Weekly Stress Chart Section
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text("Your Weekly Stress Level")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color( "navyBlue"))
                                
                                Text("From your journal entries")
                                    .font(.caption)
                                    .foregroundStyle(Color( "#skyBlue"))
                            }
                            
                            // Chart container with enhanced styling
                            VStack {
                                JournalChartView(journalData: listJournalVM.allJournalThisWeek)
                                    .padding()
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color( "skyBlue").opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 4)
                        
                        // History Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recent Entries")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color( "navyBlue"))
                                
                                Spacer()
                                
                                if !listJournalVM.allJournalHistories.isEmpty {
                                    Text("\(listJournalVM.allJournalHistories.count) entries this week")
                                        .font(.caption)
                                        .foregroundStyle(Color("emeraldGreen"))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(Color( "emeraldGreen").opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            
                            // Journal entries
                            LazyVStack(spacing: 12) {
                                if listJournalVM.allJournalThisWeek.isEmpty {
                                    // Empty state
                                    VStack(spacing: 16) {
                                        Image(systemName: "book.closed")
                                            .font(.system(size: 48))
                                            .foregroundColor(Color( "skyBlue").opacity(0.6))
                                        
                                        VStack(spacing: 8) {
                                            Text("No entries yet")
                                                .font(.headline)
                                                .foregroundColor(Color("navyBlue"))
                                            
                                            Text("Start your journaling journey by tapping the + button")
                                                .font(.subheadline)
                                                .foregroundColor(Color("skyBlue"))
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                    .padding(.vertical, 40)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.5))
                                    .cornerRadius(16)
                                } else {
                                    ForEach(listJournalVM.allJournalHistories, id: \.id) { journal in
                                        JournalCardView(journal: journal)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 100) // Space for floating button
                    }
                    .padding(.horizontal, 20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAdding = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [Color("coralOrange"), Color( "coralOrange").opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color( "coralOrange").opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .accessibilityIdentifier("addBookButton")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
        .environmentObject(AuthViewModel())
        .environmentObject(JournalViewModel())
}
