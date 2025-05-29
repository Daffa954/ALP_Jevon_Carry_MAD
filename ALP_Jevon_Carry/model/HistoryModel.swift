//
//  HistoryModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import Foundation

struct HistoryModel: Hashable, Identifiable, Codable{
    var id = UUID()
    var type: String
    var totalScore: Int
    var date: Date
    var summary: String
    var userID: String = ""
}
