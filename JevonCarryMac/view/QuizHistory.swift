//
//  QuizHistory.swift
//  ALP_Jevon_Carry
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct QuizHistory: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("Test Results")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !historyViewModel.historyList.isEmpty {
                        Text("Your Assessment History")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                    HStack{
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .padding(8)
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
                .padding(.horizontal, 20)
                
                
                if historyViewModel.historyList.isEmpty {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.08))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            
                            VStack(spacing: 8) {
                                Text("No History Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text("Complete your first test to see results and track your progress over time")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(2)
                                    .padding(.horizontal, 32)
                            }
                        }
                        
                        VStack(spacing: 12) {
                            Button(action:{
                                dismiss()
                            }){
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text("Start your first assessment")
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(historyViewModel.historyList.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Text("Total Assessments")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                }
                                
                                Spacer()
                                
                                if let latestHistory = historyViewModel.historyList.first {
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Latest")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .textCase(.uppercase)
                                            .tracking(0.5)
                                        
                                        Text(latestHistory.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                            
                            ForEach(historyViewModel.historyList) { history in
                                QuizCardHistory(history: history)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.8).combined(with: .opacity)
                                    ))
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .background(
                Color.gray.opacity(0.02)
                    .ignoresSafeArea()
            )
        }
        .onChange(of: authViewModel.user?.uid ?? "") { newUserID in
            historyViewModel.fetchHistory(userID: newUserID)
        }
        .onAppear {
            historyViewModel.fetchHistory(userID: authViewModel.user?.uid ?? "")
        }
        
    }
}

#Preview {
    QuizHistory()
        .environmentObject(HistoryViewModel())
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
}
