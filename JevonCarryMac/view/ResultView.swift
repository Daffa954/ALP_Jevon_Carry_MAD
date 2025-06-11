//
//  ResultView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 28/05/25.
//


import SwiftUI

struct ResultView: View {
    let result: HistoryModel
    @EnvironmentObject var quizViewModel: QuizViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var goHome: Bool
    
    var body: some View {
        let mainColor = Color(red: 0.286, green: 0.561, blue: 0.816)
        let lowercaseSummary = result.summary.lowercased()
        
        let summaryColor: Color = {
            if lowercaseSummary.contains("minimal or no depression") ||
                lowercaseSummary.contains("minimal anxiety") {
                return .green
            } else if lowercaseSummary.contains("mild depression") ||
                        lowercaseSummary.contains("mild anxiety") {
                return .yellow
            } else if lowercaseSummary.contains("moderate depression") ||
                        lowercaseSummary.contains("moderately severe depression") ||
                        lowercaseSummary.contains("moderate anxiety") {
                return .orange
            } else if lowercaseSummary.contains("severe depression") ||
                        lowercaseSummary.contains("severe anxiety") {
                return .red
            } else {
                return .primary
            }
        }()
        
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        mainColor.opacity(0.25),
                        Color(.blue).opacity(0.2)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 40))
                                .foregroundColor(mainColor)
                            
                            Text("Result Summary")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 16) {
                            // Assessment Type
                            HStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.title2)
                                    .foregroundColor(mainColor)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Assessment Type")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(result.type)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .background(Color(.blue).opacity(0.2))
                            .cornerRadius(16)
                            .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            // Total Score
                            HStack(spacing: 16) {
                                Image(systemName: "number")
                                    .font(.title2)
                                    .foregroundColor(mainColor)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Total Score")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(result.totalScore)")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(mainColor)
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .background(Color(.blue).opacity(0.2))
                            .cornerRadius(16)
                            .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            // Date
                            HStack(spacing: 16) {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .foregroundColor(mainColor)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Assessment Date")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(result.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                            }
                            .padding(20)
                            .background(Color(.blue).opacity(0.2))
                            .cornerRadius(16)
                            .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 2)
                            
                            // Summary
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.title2)
                                        .foregroundColor(mainColor)
                                    
                                    Text("Summary")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                
                                Text(result.summary)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(summaryColor)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(summaryColor.opacity(0.1))
                                    .cornerRadius(12)
                            }
                            .padding(20)
                            .background(Color(.blue).opacity(0.2))
                            .cornerRadius(16)
                            .shadow(color: Color.primary.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        // Recommendations Section
                        if !quizViewModel.isLoading && (!quizViewModel.recommendations.isEmpty || !quizViewModel.errorMessage.isEmpty) {
                            Text("Activity Recommendations")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.top, 20)
                        }
                        
                        // Loading Indicator
                        if quizViewModel.isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.orange)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        
                        // Display Recommendations
                        ForEach(quizViewModel.recommendations, id: \.self) { activity in
                            RecommendationCardView(activity: activity)
                        }
                        
                        // Error Message Display
                        if !quizViewModel.errorMessage.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                                Text(quizViewModel.errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    quizViewModel.getRecommendations(result)
                                }) {
                                    Text("Try Again")
                                        .font(.subheadline.weight(.semibold))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Empty State (no recommendations but no error)
                        if quizViewModel.recommendations.isEmpty &&
                           !quizViewModel.isLoading &&
                           quizViewModel.errorMessage.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                Text("No recommendations available")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Back to Home Button
                        Button(action: {
                            goHome.toggle()
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Back to Home")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(mainColor)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                quizViewModel.getRecommendations(result)
            }
        }
    }
}

#Preview {
    ResultView(result: HistoryModel(
        type: "PHQ-9",
        totalScore: 10,
        date: Date(),
        summary: "Moderate depression",
        userID: "sssssssssssss"
    ), goHome: .constant(true))
    .environmentObject(HistoryViewModel())
}
