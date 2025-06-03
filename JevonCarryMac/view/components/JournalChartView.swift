//
//  JournalChartView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 24/05/25.
//

import SwiftUI
import Charts

struct JournalChartView: View {
    var journalData: [JournalModel]
    

    var body: some View {
        VStack {
            Chart(journalData) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Score", entry.score)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color("navyBlue")) // Use Primary Blue for the line
                .symbol(.circle) // Use built-in circle symbol
                .symbolSize(80) // Slightly larger symbols for desktop
            }
            .onAppear {
                print("Journal data for chart:", journalData)
            }
            .chartXAxis {
                AxisMarks(values: journalData.map { $0.date }) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                    AxisTick(length: 5) // Solid, slightly longer ticks, adapts to dark mode
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.caption) // Smaller font for axis labels
                                .foregroundColor(Color("navyBlue")) // System secondary for adaptability
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(preset: .automatic, values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2]))
                    
                    AxisTick(length: 5) // Solid, slightly longer ticks, adapts to dark mode
                    AxisValueLabel() {
                        if let score = value.as(Int.self) {
                            Text("\(score)") // Display integer scores
                                .font(.caption)
                                .foregroundColor(Color("skyBlue"))
                        }
                    }
                }
            }
            .chartYScale(domain: 0...10) // Changed to 0...10 for better visual range if scores go higher
            .frame(height: 280) // Slightly taller chart for macOS
        }
        // Applying a consistent background for the chart area
        // Using `Color.clear` here, so the parent `VStack` in JournalView should have a background.
        .background(Color.clear)
        .cornerRadius(18) // Maintain corner radius
    }
}


#Preview {
    JournalChartView(journalData: [
        JournalModel(title: "Entry 1", date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, description: "Description 1", emotion: "joy", score: 5),
        JournalModel(title: "Entry 2", date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, description: "Description 2", emotion: "sadness", score: 2),
        JournalModel(title: "Entry 3", date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, description: "Description 3", emotion: "anger", score: 7),
        JournalModel(title: "Entry 4", date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, description: "Description 4", emotion: "anticipation", score: 8),
        JournalModel(title: "Entry 5", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, description: "Description 5", emotion: "surprise", score: 4),
        JournalModel(title: "Entry 6", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, description: "Description 6", emotion: "trust", score: 6),
        JournalModel(title: "Entry 7", date: Date(), description: "Description 7", emotion: "joy", score: 9)
    ])
}
