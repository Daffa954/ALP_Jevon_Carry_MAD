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
    //MODEL 1
    private let model: EmotionClassifierV5?
    //MODEL 2
    private let model2: EmotionClassifierOpt?

    init() {
        model = try? EmotionClassifierV5(configuration: MLModelConfiguration())
        model2 = try? EmotionClassifierOpt(configuration: MLModelConfiguration())
    }


    func classifyEmotion(from text: String) -> String {
        //APABILA DEVICE TIDAK SUPPORT MODEL 1 akan berganti ke model 2
        if let model = model, let prediction = try? model.prediction(text: text) {
            return prediction.label
        } else if let model2 = model2, let prediction = try? model2.prediction(text: text) {
            return prediction.label
        } else {
            return "Unknown"
        }
    }

}
