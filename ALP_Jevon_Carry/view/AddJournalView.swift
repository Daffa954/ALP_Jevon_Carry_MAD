//
//  AddJournalView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct AddJournalView: View {
    @Binding var isAddJournal: Bool
    @State private var isEditing = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State var isAnalyzed: Bool = false
    var body: some View {
        
        VStack() {
            // Header with icon
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(Color("navyBlue"))
                    .font(.system(size: 28))
                
                Text("New Journal Entry")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Color("navyBlue"))
            }
            
            
            
            VStack() {
                TextEditor(text: $journalViewModel.userInput)
                
                    .frame(minHeight: 200,maxHeight: 300)
                    
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("skyBlue"), lineWidth: 2)
                    )
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .onTapGesture {
                        isEditing = true
                    }
            }
            
            //            // Character Counter
            HStack {
                Spacer()
                Text("\(journalViewModel.userInput.count)/1000")
                    .font(.caption)
                    .foregroundColor(journalViewModel.userInput.count > 1000 ? .red : .gray)
            }.padding(.bottom, 20)
            
            // Save Button
            HStack{
                Button("Cancel") {
                    dismiss()
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
                
                Button(action: {
                    journalViewModel.analyzeEmotion()
                    isAnalyzed = true
                }) {
                    HStack {
                        
                        Text("Save and Analyze")
                            .font(.headline)
                        
                        
                    }
                    
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(journalViewModel.userInput.isEmpty)
            }
            //result card
            if isAnalyzed {
                Text("Your Result:")
                    .font(.title2)
                    .padding(.top, 10)
                
                ResultCardView(journal: journalViewModel.result ?? JournalModel(id: UUID(), title: "", date: Date(), description: "", emotion: "", score: 0))
                
                Spacer()
            }

              Spacer()
        }
        .padding(.horizontal, 25)
        
    }
    
}



#Preview {
    NavigationStack {
        AddJournalView(isAddJournal: .constant(true))
            .environmentObject(JournalViewModel())
        
    }
}

struct ResultCardView: View {
    let journal: JournalModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Emotion Icon
            ZStack {
                Circle()
                    .fill(emotionColor(for: journal.emotion).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(emojiForEmotion(journal.emotion))
                    .font(.system(size: 24))
            }
            
            // Journal Details
            VStack(alignment: .leading, spacing: 6) {
                Text(journal.title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                HStack(spacing: 12) {
                    Text(journal.emotion.capitalized)
                        .font(.subheadline)
                        .foregroundColor(emotionColor(for: journal.emotion))
                    
                    Text("\(journal.score)/10")
                        .font(.subheadline)
                        .foregroundColor(scoreColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(scoreColor.opacity(0.2)))
                }
                
                Text(journal.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
    
    // Calculate score color based on value
    private var scoreColor: Color {
        switch journal.score {
        case 0...3: return .red
        case 4...6: return .orange
        case 7...10: return .green
        default: return .gray
        }
    }
    
    // Map emotions to emojis
    private func emojiForEmotion(_ emotion: String) -> String {
        switch emotion.lowercased() {
        case "joy": return "😊"
        case "trust": return "🤝"
        case "fear": return "😨"
        case "surprise": return "😲"
        case "sadness": return "😢"
        case "disgust": return "🤢"
        case "anger": return "😠"
        case "anticipation": return "🤔"
        default: return "❓"
        }
    }
    
    // Map emotions to colors
    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "joy": return .green
        case "trust": return .green
        case "fear": return .red
        case "surprise": return .yellow
        case "sadness": return .red
        case "disgust": return .red
        case "anger": return .red
        case "anticipation": return .yellow
        default: return .gray
        }
    }
}

struct ResultCardView_Previews: PreviewProvider {
    static var previews: some View {
        ResultCardView(journal: JournalModel(
            title: "Best Day Ever!",
            date: Date(),
            description: "Had an amazing time at the park with friends",
            emotion: "excited",
            score: 9
        ))
        .padding()
        .previewLayout(.sizeThatFits)
        .environment(\.colorScheme, .light)
    }
}
