//
//  File.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 23/05/25.
//

import Foundation

struct JournalModel: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var description: String
    var emotion: String
    var score: Int
    var userID : String = ""
}
