//
//  QuizCardHistory.swift
//  ALP_Jevon_Carry
//
//  Created by student on 30/05/25.
//

import SwiftUI

struct QuizCardHistory: View {
    let history: HistoryModel
    private let mainColor = Color(red: 0.286, green: 0.561, blue: 0.816) // #498FD0
    
    private var summaryColor: Color {
        let lowercaseSummary = history.summary.lowercased()
        
        if lowercaseSummary.contains("minimal or no depression") ||
            lowercaseSummary.contains("minimal anxiety") {
            return Color.green
        } else if lowercaseSummary.contains("mild depression") ||
                    lowercaseSummary.contains("mild anxiety") {
            return Color.yellow
        } else if lowercaseSummary.contains("moderate depression") ||
                    lowercaseSummary.contains("moderately severe depression") ||
                    lowercaseSummary.contains("moderate anxiety") {
            return Color.orange
        } else if lowercaseSummary.contains("severe depression") ||
                    lowercaseSummary.contains("severe anxiety") {
            return Color.red
        } else {
            return Color.primary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(history.type)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(mainColor)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Score: \(history.totalScore)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    HStack{
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Date")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    
                    Text(history.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(summaryColor)
                        .frame(width: 8, height: 8)
                    
                    Text("Assessment Summary")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                
                Text(history.summary)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(summaryColor)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(summaryColor.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(summaryColor.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 12,
                    x: 0,
                    y: 4
                )
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    QuizCardHistory(history: HistoryModel(
            type: "PHQ-9",
            totalScore: 12,
            date: Date(),
            summary: "Moderate depression",
            userID: "123"
        ))
}
