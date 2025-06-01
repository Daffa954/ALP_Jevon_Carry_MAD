//
//  QuizViewModel.swift
//  ALP_Jevon_Carry
//
//  Created by student on 28/05/25.
//

import Foundation

@MainActor
class QuizViewModel: ObservableObject {
    @Published var type: String
    @Published var questions: [QuestionModel] = []
    @Published var selectedAnswers: [Int: Int] = [:]
    
    
    init(type: String) {
        self.type = type
        self.questions = loadQuestions()
    }
    
    
    private func loadQuestions() -> [QuestionModel] {
        if type == "PHQ-9" {
            return [
                QuestionModel(id: 1, text: "Little interest or pleasure in doing things?"),
                QuestionModel(id: 2, text: "Feeling down, depressed, or hopeless?"),
                QuestionModel(id: 3, text: "Trouble falling or staying asleep, or sleeping too much?"),
                QuestionModel(id: 4, text: "Feeling tired or having little energy?"),
                QuestionModel(id: 5, text: "Poor appetite or overeating?"),
                QuestionModel(id: 6, text: "Feeling bad about yourself — or that you are a failure or have let yourself or your family down?"),
                QuestionModel(id: 7, text: "Trouble concentrating on things, such as reading the newspaper or watching television?"),
                QuestionModel(id: 8, text: "Moving or speaking so slowly that other people could have noticed? Or so fidgety or restless that you have been moving a lot more than usual?"),
                QuestionModel(id: 9, text: "Thoughts that you would be better off dead, or thoughts of hurting yourself in some way?")
            ]
        } else if type == "GAD-7" {
            return [
                QuestionModel(id: 1, text: "Feeling nervous, anxious or on edge"),
                QuestionModel(id: 2, text: "Not being able to stop worrying"),
                QuestionModel(id: 3, text: "Worrying too much about different things"),
                QuestionModel(id: 4, text: "Trouble relaxing"),
                QuestionModel(id: 5, text: "Being so restless that it's hard to sit still"),
                QuestionModel(id: 6, text: "Becoming easily annoyed or irritable"),
                QuestionModel(id: 7, text: "Feeling afraid as if something awful might happen")
            ]
        } else {
            return []
        }
        
    }
    
    func getAnswerOptions() -> [AnswerModel] {
        return [
            AnswerModel(id: 0, text: "Not at all", score: 0),
            AnswerModel(id: 1, text: "Several days", score: 1),
            AnswerModel(id: 2, text: "More than half the days", score: 2),
            AnswerModel(id: 3, text: "Nearly every day", score: 3)
        ]
    }
    
    func totalScore() -> Int {
        selectedAnswers.values.reduce(0, +)
    }
    
    func getSummary(score: Int) -> String {
        if type == "PHQ-9" {
            switch score {
            case 0...4: return "Minimal or no depression"
            case 5...9: return "Mild depression"
            case 10...14: return "Moderate depression"
            case 15...19: return "Moderately severe depression"
            default: return "Severe depression"
            }
        } else {
            switch score {
            case 0...4: return "Minimal anxiety"
            case 5...9: return "Mild anxiety"
            case 10...14: return "Moderate anxiety"
            default: return "Severe anxiety"
            }
        }
    }
    
    func saveHistory(userID: String) -> HistoryModel {
        let score = totalScore()
        return HistoryModel(
            type: type,
            totalScore: score,
            date: Date(),
            summary: getSummary(score: score),
            userID: userID
        )
    }
}
