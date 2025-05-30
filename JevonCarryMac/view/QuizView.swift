//
//  QuizView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct QuizView: View {
    @EnvironmentObject var quizViewModel: QuizViewModel
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @State private var showResult = false
    @State private var result: HistoryModel? = nil
    @State private var score: Int = 0
    var type: String
    @StateObject private var quizVM: QuizViewModel
    
    init(type: String) {
        self.type = type
        _quizVM = StateObject(wrappedValue: QuizViewModel(type: type))
    }
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(score)")
                    HStack{
                        Spacer()
                        Text("Quiz \(quizViewModel.type)")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    
                    ForEach(quizViewModel.questions) { question in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.text)
                                .font(.headline)
                            
                            let options = quizViewModel.getAnswerOptions()
                            
                            ForEach(options) { option in
                                HStack {
                                    let isSelected = quizViewModel.selectedAnswers[question.id] == option.score
                                    
                                    Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                        .onTapGesture {
                                            quizViewModel.selectedAnswers[question.id] = option.score
                                        }
                                        .foregroundColor(isSelected ? .blue : .gray)
                                    Text(option.text)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    
                    Button("Submit") {
                        let history = quizViewModel.saveHistory()
                        result = history
                        historyViewModel.addHistory(history)
                        showResult = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(quizViewModel.selectedAnswers.count != quizViewModel.questions.count)
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    
                    
                }
                .padding()
                .padding(.horizontal, 8)
            }
            .sheet(isPresented: $showResult) {
                if let result = result {
                    ResultView(result: result)
                }
            }
        }
        
    }
}

#Preview {
    QuizView(type: "PHQ-9")
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())
}
