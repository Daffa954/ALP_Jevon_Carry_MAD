//
//  AnswerModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import Foundation

struct AnswerModel: Hashable, Identifiable, Codable{
    var id: Int
    var text: String
    var score: Int
}
