//
//  AddJournalView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct AddJournalView: View {
    @Binding var isAddJournal: Bool
    @State private var isEditing = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var userViewModel: AuthViewModel
    @State var isAnalyzed: Bool = true
    @State var userID: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color("lightGray1"), Color( "lightGray1").opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color( "skyBlue"), Color( "skyBlue").opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color( "skyBlue").opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "book.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 32, weight: .medium))
                            }
                            
                            VStack(spacing: 4) {
                                Text("New Journal Entry")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("navyBlue"))
                                
                                Text("Share your thoughts and feelings")
                                    .font(.subheadline)
                                    .foregroundColor(Color("skyBlue"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Writing Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Write your thoughts")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color("navyBlue"))
                                Spacer()
                                
                                // Character counter with better styling
                                Text("\(journalViewModel.userInput.count)/1000")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(characterCountColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(characterCountColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Enhanced text editor
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color( "skyBlue").opacity(0.08), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isEditing ? Color("skyBlue") : Color("lightGray1"),
                                                lineWidth: isEditing ? 2 : 1
                                            )
                                    )
                                
                                VStack {
                                    
                                    TextEditor(text: $journalViewModel.userInput)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .font(.body)
                                        .foregroundColor(Color("navyBlue"))
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isEditing = true
                                            }
                                        }
                                }
                                .padding(16)
                            }
                            .frame(minHeight: 200, maxHeight: 300)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(Color("coralOrange"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color( "coralOrange").opacity(0.1))
                            .cornerRadius(12)
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    journalViewModel.analyzeEmotion(userID: userViewModel.myUser.uid)
                                    isAnalyzed = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if journalViewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "brain.head.profile")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    Text(journalViewModel.isLoading ? "Analyzing..." : "Save & Analyze")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: journalViewModel.userInput.isEmpty ?
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                            [Color("emeraldGreen"), Color( "emeraldGreen").opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(
                                    color: journalViewModel.userInput.isEmpty ?
                                    Color.clear : Color( "emeraldGreen").opacity(0.3),
                                    radius: 6, x: 0, y: 3
                                )
                            }
                            .disabled(journalViewModel.userInput.isEmpty || journalViewModel.isLoading)
                        }
                        
                        // Results Section
                        if isAnalyzed && !journalViewModel.isLoading {
                            VStack(spacing: 20) {
                                if !journalViewModel.result.title.isEmpty {
                                    // Analysis Result
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.title2)
                                                .foregroundColor(Color("skyBlue"))
                                            
                                            Text("Analysis Result")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("navyBlue"))
                                            
                                            Spacer()
                                        }
                                        
                                        ResultCardView(journal: journalViewModel.result)
                                    }
                                    
                                    // Activity Recommendations
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.title2)
                                                .foregroundColor(Color("coralOrange"))
                                            
                                            Text("Recommended Activities")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("navyBlue"))
                                            
                                            Spacer()
                                        }
                                        
                                        if let error = journalViewModel.errorMessage {
                                            VStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .font(.title2)
                                                    .foregroundColor(Color( "coralOrange"))
                                                
                                                Text(error)
                                                    .font(.body)
                                                    .foregroundColor(Color("coralOrange"))
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                            .background(Color( "coralOrange").opacity(0.1))
                                            .cornerRadius(12)
                                        } else if journalViewModel.recommendations.isEmpty {
                                            VStack(spacing: 8) {
                                                Image(systemName: "hourglass.tophalf.filled")
                                                    .font(.title2)
                                                    .foregroundColor(Color( "skyBlue"))
                                                
                                                Text("No recommendations available yet.")
                                                    .font(.body)
                                                    .foregroundColor(Color( "skyBlue"))
                                            }
                                            .padding()
                                            .background(Color( "skyBlue").opacity(0.1))
                                            .cornerRadius(12)
                                        } else {
                                            LazyVStack(spacing: 12) {
                                                ForEach(journalViewModel.recommendations, id: \.self) { activity in
                                                    RecommendationCardView(activity: activity)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.5), value: journalViewModel.result.title)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing = false
            }
        }
    }
    
    private var characterCountColor: Color {
        if journalViewModel.userInput.count > 1000 {
            return Color("coralOrange")
        } else if journalViewModel.userInput.count > 800 {
            return Color("coralOrange").opacity(0.7)
        } else {
            return Color("skyBlue")
        }
    }
}




#Preview {
    NavigationStack {
        AddJournalView(isAddJournal: .constant(true), userID: "fBdMKF5GIvMuufer7JqzgPgVwEI2")
            .environmentObject(JournalViewModel())
    }
}
