//
//  ResultView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 28/05/25.
//

import SwiftUI

struct ResultView: View {
//    @EnvironmentObject var historyViewModel: HistoryViewModel
    let result: HistoryModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Result Summary")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 40)
            
            Text("Type : \(result.type)")
            Text("Score : \(result.totalScore)")
            Text("Date : \(result.date.formatted(date: .abbreviated, time: .shortened))")
            Text("Summary : \(result.summary)")
            
            Spacer()
            Button("Back to Home") {
                dismiss()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        
    }
}

#Preview {
    ResultView(result: HistoryModel(
            type: "PHQ-9",
            totalScore: 10,
            date: Date(),
            summary: "Moderate depression"
        ))
        .environmentObject(HistoryViewModel())
}
