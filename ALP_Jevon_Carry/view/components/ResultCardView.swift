//
//  ResultCardView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 28/05/25.
//

import SwiftUI

struct ResultCardView: View {
    let journal: JournalModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced emotion icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [emotionColor(for: journal.emotion), emotionColor(for: journal.emotion).opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: emotionColor(for: journal.emotion).opacity(0.3), radius: 6, x: 0, y: 3)
                
                Text(emojiForEmotion(journal.emotion))
                    .font(.system(size: 28))
            }
            
            // Journal details with enhanced styling
            VStack(alignment: .leading, spacing: 8) {
                Text(journal.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("navyBlue"))
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    // Emotion tag
                    Text(journal.emotion.capitalized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(emotionColor(for: journal.emotion))
                        .cornerRadius(8)
                    
                    // Score indicator
                    HStack(spacing: 4) {
                        Image(systemName: scoreIcon)
                            .font(.caption)
                        Text("\(journal.score)/10")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(scoreColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(scoreColor.opacity(0.15))
                    .cornerRadius(8)
                }
                
                Text(journal.date, style: .date)
                    .font(.caption)
                    .foregroundColor(Color( "skyBlue"))
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color("skyBlue").opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color("lightGray1"), lineWidth: 1)
        )
    }
    
    private var scoreColor: Color {
        switch journal.score {
        case 0...3: return Color("coralOrange")
        case 4...6: return Color( "coralOrange").opacity(0.8)
        case 7...10: return Color.red
        default: return Color( "skyBlue")
        }
    }
    
    private var scoreIcon: String {
        switch journal.score {
        case 0...3: return "arrow.down.circle.fill"
        case 4...6: return "minus.circle.fill"
        case 7...10: return "arrow.up.circle.fill"
        default: return "circle.fill"
        }
    }
    
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
    
    private func emotionColor(for emotion: String) -> Color {
        switch emotion.lowercased() {
        case "joy": return Color("emeraldGreen")
        case "trust": return Color("skyBlue")
        case "fear": return Color("coralOrange")
        case "surprise": return Color("skyBlue")
        case "sadness": return Color("navyBlue")
        case "disgust": return Color("coralOrange")
        case "anger": return Color("coralOrange")
        case "anticipation": return Color("skyBlue")
        default: return Color("navyBlue")
        }
    }
}


//#Preview {
//    ResultCardView()
//}
