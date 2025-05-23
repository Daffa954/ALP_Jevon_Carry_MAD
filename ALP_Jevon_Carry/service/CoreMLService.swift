//
//  CoreMLService.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 16/05/25.
//

import Foundation
import CoreML

class CoreMLService {
    static let shared = CoreMLService()
    
    private let model: EmotionClassifierV5?

    init() {
        model = try? EmotionClassifierV5(configuration: MLModelConfiguration())
    }

    func classifyEmotion(from text: String) -> String {
        guard let model = model else { return "Unknown" }
        let prediction = try? model.prediction(text: text)
        return prediction?.label ?? "Unknown"
    }
}
