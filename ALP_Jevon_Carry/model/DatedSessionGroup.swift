//
//  DatedSessionGroup.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

import Foundation

struct DatedSessionGroup: Identifiable, Hashable {
    let id: Date
    var sessions: [BreathingSession]
}
