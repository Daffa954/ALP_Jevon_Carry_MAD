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
            .onAppear {
                print("Journal data for chart:", journalData)
            }
            .chartXAxis {
//                AxisMarks(values: .automatic(desiredCount: 5)) { value in
//                    AxisGridLine()
//                    AxisTick()
//                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
//                    
//                }
                
                                AxisMarks(values: journalData.map { $0.date }) { value in
                                    AxisGridLine()
                                    AxisTick()
                                    if let date = value.as(Date.self) {
                                        AxisValueLabel {
                                            Text(date.formatted(.dateTime.day().month(.abbreviated)))
                                        }
                                    }
                                }
            }
            .chartYScale(domain: 0...9)
            .frame(height: 250)
          
        }
    }
}
