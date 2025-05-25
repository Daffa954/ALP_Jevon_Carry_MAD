//
//  JournalChartView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 24/05/25.
//

import SwiftUI
import Charts

// Dummy Data
let journalData: [JournalModel] = [
    .init(title: "Jumat", date: Date().addingTimeInterval(-86400 * 7), description: "Great day", emotion: "positive", score: 5, ),
    .init(title: "Jumat", date: Date().addingTimeInterval(-86400 * 6), description: "Great day", emotion: "positive", score: 5, ),
    .init(title: "Jumat", date: Date().addingTimeInterval(-86400 * 5), description: "Great day", emotion: "positive", score: 5, ),
    .init(title: "Jumat", date: Date().addingTimeInterval(-86400 * 5), description: "Great day", emotion: "positive", score: 9, ),
    .init(title: "Senin", date: Date().addingTimeInterval(-86400 * 4), description: "Feeling good", emotion: "positive", score: 3),
    .init(title: "Selasa", date: Date().addingTimeInterval(-86400 * 3), description: "Stressful day", emotion: "negative", score: 1),
    .init(title: "Rabu", date: Date().addingTimeInterval(-86400 * 2), description: "Okay", emotion: "neutral", score: 2),
    .init(title: "Kamis", date: Date().addingTimeInterval(-86400 * 0), description: "Excited!", emotion: "excited", score: 4),
    
]

struct JournalChartView: View {
    var body: some View {
        VStack{
           
            Chart(journalData) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Score", entry.score)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(.blue)
                .symbol(Circle())
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    
                }
            }
            .chartYScale(domain: 0...9)
            .frame(height: 250)
          
        }
    }
}
#Preview {
    JournalChartView()
}
