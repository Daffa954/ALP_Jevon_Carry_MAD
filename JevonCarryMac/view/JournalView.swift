//
//  JournalView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI
import Charts // Keep Charts import if it's used elsewhere, though not directly in this file's main body

struct JournalView: View {
    @State var isAdding: Bool = false
    @EnvironmentObject var listJournalVM: ListJournalViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color (lighter for macOS, better for both modes)
                // Using a solid color or a subtle gradient that adapts better
                Color("lightGray1") // Neutral background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) { // Increased spacing for desktop layout
                        // Header Section
                        VStack(alignment: .leading, spacing: 6) { // Align header to leading, increased spacing
                            Text("My Journal")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color("navyBlue")) // Navy Blue for strong headings
                            
                            Text("Welcome back, \(authVM.myUser.name)!")
                                .font(.title3) // Slightly larger subheadline for macOS
                                .foregroundColor(Color("skyBlue")) // Sky Blue for a friendly greeting
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensure header is leading aligned
                        .padding(.horizontal) // Add horizontal padding for the header
                        
                        // Weekly Stress Chart Section
                        VStack(alignment: .leading, spacing: 20) { // Increased spacing for desktop
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Your Weekly Stress Level")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("navyBlue"))
                                
                                Text("From your journal entries")
                                    .font(.callout) // Adjusted font size
                                    .foregroundColor(.secondary) // System secondary for adaptability
                            }
                            
                            // Chart container with enhanced styling
                            VStack {
                                JournalChartView(journalData: listJournalVM.allJournalThisWeek)
                                    .padding()
                            }
                            .background(Color.white) // White background for the chart
                            .cornerRadius(18) // More rounded corners
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5) // Softer, slightly larger shadow
                        }
                        .padding(.horizontal) // Add horizontal padding for the chart section
                        
                        // History Section
                        VStack(alignment: .leading, spacing: 20) { // Increased spacing
                            HStack {
                                Text("Recent Entries")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("navyBlue"))
                                
                                Spacer()
                                
                                if !listJournalVM.allJournalHistories.isEmpty {
                                    Text("\(listJournalVM.allJournalHistories.count) entries this week")
                                        .font(.caption)
                                        .foregroundColor(Color("emeraldGreen")) // Emerald Green for positive count
                                        .padding(.horizontal, 14) // Slightly more padding
                                        .padding(.vertical, 6)
                                        .background(Color("emeraldGreen").opacity(0.15)) // Slightly stronger background for clarity
                                        .cornerRadius(15) // More rounded corners
                                }
                            }
                            
                            // Journal entries
                            LazyVStack(spacing: 15) { // Increased spacing between cards
                                if listJournalVM.allJournalThisWeek.isEmpty {
                                    // Empty state
                                    VStack(spacing: 20) { // Increased spacing
                                        Image(systemName: "book.closed")
                                            .font(.system(size: 60)) // Larger icon
                                            .foregroundColor(Color("skyBlue").opacity(0.7)) // More prominent Sky Blue
                                        
                                        VStack(spacing: 10) { // Increased spacing
                                            Text("No entries yet")
                                                .font(.title2)
                                                .foregroundColor(Color("navyBlue"))
                                            
                                            Text("Start your journaling journey by clicking the + button above.") // Adjusted text for macOS
                                                .font(.body) // Changed to body for readability
                                                .foregroundColor(.secondary) // System secondary color
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                    .padding(.vertical, 50) // More vertical padding
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.7)) // Slightly more opaque background
                                    .cornerRadius(18) // More rounded corners
                                } else {
                                    ForEach(listJournalVM.allJournalHistories, id: \.id) { journal in
                                        JournalCardView(journal: journal)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal) // Add horizontal padding for the history section
                        
                        Spacer(minLength: 80) // Space for floating button
                    }
                    .padding(.vertical, 20) // Add vertical padding to the overall scroll content
                }
            }
            .toolbar {
                ToolbarItem() { // Use trailing for macOS toolbar
                    Button(action: {
                        isAdding = true
                    }) {
                        Image(systemName: "plus") // A more prominent plus icon
                            .font(.system(size: 30)) // Larger icon
                            .foregroundColor(Color("coralOrange")) // Coral Orange for the accent button
                            .symbolRenderingMode(.palette) // Ensures color application
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2) // Subtle shadow
                    }
                    .buttonStyle(.plain) // Use plain button style for toolbar items
                    .accessibilityIdentifier("addJournalButton") // Updated identifier
                }
            }
            .navigationDestination(isPresented: $isAdding, destination: {
                AddJournalView(isAddJournal: $isAdding, userID: authVM.myUser.uid)
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
            .onChange(of: isAdding) { wasAdding, isNowAdding in
                if wasAdding == true && isNowAdding == false {
                    // Setelah keluar dari AddJournalView
                    listJournalVM.fetchJournalThisWeek(userID: authVM.myUser.uid)
                    listJournalVM.fetchAllJournal(userID: authVM.myUser.uid)
                }
            }
        }
    }
}


#Preview {
    JournalView()
        .environmentObject(ListJournalViewModel())
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
        .environmentObject(JournalViewModel())
}
