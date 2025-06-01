//
//  QuizView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct QuizView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var result: HistoryModel? = nil
    @State private var score: Int = 0
    var type: String
    @StateObject private var quizVM: QuizViewModel
    
    @State var goHome: Bool = false
    @State private var showResult = false
    @Environment(\.dismiss) var dismiss
    
    //    @Binding var tab: TabItemEnum
    //    @Binding var isPresented: Bool
    
    init(type: String) {
        self.type = type
        _quizVM = StateObject(wrappedValue: QuizViewModel(type: type))
        //        self._tab = tab
        //        self._isPresented = isPresented
    }
    var body: some View {
        let mainColor = Color(red: 0.286, green: 0.561, blue: 0.816) // #498FD0
        
        NavigationStack {
            
            HStack{
                //                HStack {
                //                    Image(systemName: "chevron.backward")
                //                        .foregroundColor(.blue)
                //                    Text("Back")
                //                        .foregroundStyle(.blue)
                //                }
                //                .padding(.leading)
                //                .onTapGesture {
                //                    dismiss()
                //                }
                Spacer()
            }
            Spacer()
            
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        mainColor.opacity(0.25),
                        Color.white
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()
                
                
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        
                        
                        HStack{
                            
                            VStack(spacing: 16) {
                                Text("Quiz \(quizVM.type)")
                                    .font(.title)
                                    .bold()
                            }
                            .padding(.top, 10)
                        }
                        
                        
                        
                        ForEach(quizVM.questions) { question in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    
                                    Text(question.text)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .lineLimit(nil)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                let options = quizVM.getAnswerOptions()
                                
                                VStack(spacing: 12) {
                                    ForEach(options) { option in
                                        let isSelected = quizVM.selectedAnswers[question.id] == option.score
                                        
                                        HStack(spacing: 16) {
                                            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                                .font(.title3)
                                                .foregroundColor(isSelected ? mainColor : .gray)
                                            
                                            Text(option.text)
                                                .font(.body)
                                                .foregroundColor(isSelected ? mainColor : .primary)
                                                .fontWeight(isSelected ? .semibold : .regular)
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(isSelected ? mainColor.opacity(0.1) : Color.gray.opacity(0.05))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? mainColor : Color.clear, lineWidth: 2)
                                        )
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.1)) {
                                                quizVM.selectedAnswers[question.id] = option.score
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        }
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(quizVM.selectedAnswers.count)/\(quizVM.questions.count)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(mainColor)
                            }
                            
                            ProgressView(value: Double(quizVM.selectedAnswers.count), total: Double(quizVM.questions.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: mainColor))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        
                        let isFormComplete = quizVM.selectedAnswers.count == quizVM.questions.count
                        
                        Button(action: {
                            let history = quizVM.saveHistory(userID: authViewModel.user?.uid ?? "")
                            result = history
                            historyViewModel.addHistory(history)
                            showResult = true
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                
                                Text("Submit Assessment")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormComplete ? mainColor : Color.gray)
                            .cornerRadius(12)
                            .shadow(color: (isFormComplete ? mainColor : Color.gray).opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isFormComplete)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showResult) {
                if let result = result {
                    ResultView(result: result, goHome: $goHome)
                }
            }
            .onChange(of: goHome){
                dismiss()
            }
        }
    }
}

#Preview {
    QuizView(type: "PHQ-9")
        .environmentObject(QuizViewModel(type: "PHQ-9"))
        .environmentObject(HistoryViewModel())
        .environmentObject(AuthViewModel(repository: FirebaseAuthRepository()))
}
