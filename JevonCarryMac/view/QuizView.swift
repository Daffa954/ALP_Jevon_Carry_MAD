//
//  QuizView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct QuizView: View {
    @EnvironmentObject var historyViewModel: HistoryViewModel
    @EnvironmentObject var quizViewModel: QuizViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var result: HistoryModel? = nil
    @State private var score: Int = 0
    var type: String
    @StateObject private var quizVM: QuizViewModel
    
    @State var goHome: Bool = false
    @State private var showResult = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme // Access color scheme

    init(type: String) {
        self.type = type
        _quizVM = StateObject(wrappedValue: QuizViewModel(type: type))
    }
    
    var body: some View {
        // Define colors from Asset Catalog as constants for easier use and type-checking
        let skyBlue = Color("skyBlue")
        let navyBlue = Color("navyBlue")
        let lightGray1 = Color("lightGray1")
        // No need for accentColor, neutralLightGray, successColor if not used directly as such
        
        NavigationStack {
            VStack(spacing: 0) { // Use VStack for overall layout on macOS
                // Header (similar to a title bar area)
                HStack {
                    Spacer()
                    Text("Quiz \(quizVM.type)")
                        .font(.largeTitle) // Larger font for macOS title
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme == .dark ? .white : navyBlue) // Adjust text color for dark/light mode
                    Spacer()
                }
                .padding(.vertical, 20) // More vertical padding for header
                // Break up expression for background
                .background({ () -> Color in
                    if colorScheme == .dark {
                        return .black.opacity(0.3)
                    } else {
                        return lightGray1
                    }
                }()) // Subtle background for header
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2) // Light shadow for separation

                // Content area
                ZStack {
                    // Background gradient adapted for macOS
                    let gradientStartColor = skyBlue.opacity(0.15)
                    let gradientEndColor = colorScheme == .dark ? Color.black : Color.white
                    let backgroundGradient = LinearGradient(
                        gradient: Gradient(colors: [gradientStartColor, gradientEndColor]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    
                    backgroundGradient
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 30) { // Increased spacing between sections
                            
                            ForEach(quizVM.questions) { question in
                                VStack(alignment: .leading, spacing: 20) { // Increased spacing for questions
                                    HStack {
                                        Text(question.text)
                                            .font(.title3) // Slightly larger font for questions
                                            .fontWeight(.semibold)
                                            .foregroundColor(colorScheme == .dark ? .white : .primary)
                                            .lineLimit(nil)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                    }
                                    
                                    let options = quizVM.getAnswerOptions()
                                    
                                    VStack(spacing: 15) { // Increased spacing between options
                                        ForEach(options) { option in
                                            let isSelected = quizVM.selectedAnswers[question.id] == option.score
                                            
                                            HStack(spacing: 20) { // Increased spacing for selection circle and text
                                                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                                                    .font(.title2) // Larger icon
                                                    .foregroundColor(isSelected ? skyBlue : .gray)
                                                
                                                Text(option.text)
                                                    .font(.body)
                                                    .foregroundColor(isSelected ? skyBlue : (colorScheme == .dark ? .white : .primary))
                                                    .fontWeight(isSelected ? .semibold : .regular)
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 20) // More horizontal padding
                                            .padding(.vertical, 15)    // More vertical padding
                                            // Break up expression for option background
                                            .background({ () -> Color in
                                                if isSelected {
                                                    return skyBlue.opacity(0.1)
                                                } else {
                                                    return colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05)
                                                }
                                            }())
                                            .cornerRadius(12)
                                            // Break up expression for option overlay stroke
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(isSelected ? skyBlue : Color.clear, lineWidth: 2)
                                            )
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    quizVM.selectedAnswers[question.id] = option.score
                                                }
                                            }
                                            .help("Select this option") // macOS specific accessibility
                                        }
                                    }
                                }
                                .padding(25) // More padding around each question block
                                // Break up expression for question block background
                                .background(colorScheme == .dark ? navyBlue.opacity(0.3) : Color.white) // Adjust background for dark mode
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5) // Stronger shadow
                            }
                            
                            VStack(spacing: 12) { // Increased spacing for progress section
                                HStack {
                                    Text("Progress")
                                        .font(.headline) // Slightly larger font
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .secondary)
                                    
                                    Spacer()
                                    
                                    Text("\(quizVM.selectedAnswers.count)/\(quizVM.questions.count)")
                                        .font(.headline) // Slightly larger font
                                        .fontWeight(.semibold)
                                        .foregroundColor(skyBlue) // Direct use as it's not a complex expression
                                }
                                
                                ProgressView(value: Double(quizVM.selectedAnswers.count), total: Double(quizVM.questions.count))
                                    .progressViewStyle(LinearProgressViewStyle(tint: skyBlue))
                                    .scaleEffect(x: 1, y: 3, anchor: .center) // Thicker progress bar
                            }
                            .padding(25) // More padding
                            .background(colorScheme == .dark ? navyBlue.opacity(0.3) : Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                            
                            let isFormComplete = quizVM.selectedAnswers.count == quizVM.questions.count
                            
                            Button(action: {
                                let history = quizVM.saveHistory(userID: authViewModel.user?.uid ?? "")
                                result = history
                                historyViewModel.addHistory(history)
                                quizViewModel.getRecommendations(history)
                                showResult = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2) // Larger icon
                                    
                                    Text("Submit Assessment")
                                        .fontWeight(.bold) // Bolder text
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20) // More vertical padding for button
                                // Break up expression for button background
                                .background(isFormComplete ? skyBlue : Color.gray)
                                .cornerRadius(12)
                                // Break up expression for button shadow color
                                .shadow(color: (isFormComplete ? skyBlue : Color.gray).opacity(0.4), radius: 10, x: 0, y: 6) // Stronger shadow
                            }
                            .disabled(!isFormComplete)
                            .padding(.horizontal, 25) // More horizontal padding
                            .padding(.top, 20) // More spacing from above content
                            .buttonStyle(.plain) // Use plain button style for macOS to remove default styling
                            
                            Spacer(minLength: 50) // More space at the bottom
                        }
                        .padding(30) // Overall padding for the scroll view content
                    }
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
