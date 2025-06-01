import SwiftUI

struct JournalCardView: View {
    var journal: JournalModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and emotion
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(journal.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("navyBlue"))
                        .lineLimit(2)
                    
                    Text(formattedDate(journal.date))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("skyBlue").opacity(0.8))
                }
                
                Spacer()
                
                // Enhanced emotion display
                VStack(spacing: 2) {
                    Text(emoticon(for: journal.emotion))
                        .font(.system(size: 32))
                    
                    Text(journal.emotion.capitalized)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(emotionColor(for: journal.emotion))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(emotionColor(for: journal.emotion).opacity(0.15))
                        )
                }
            }

            // Description
            Text(journal.description)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("navyBlue").opacity(0.8))
                .lineLimit(2)
                .lineSpacing(2)

            // Bottom section with score
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("skyBlue"))
                    
                    Text("Stress Level: \(Int(journal.score))/9")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color("skyBlue"))
                }
                
                Spacer()
                
                // Stress level indicator
                HStack(spacing: 3) {
                    ForEach(1...3, id: \.self) { index in
                        Circle()
                            .fill(index <= stressLevelIndicator(Double(journal.score)) ? stressColor(Double(journal.score)) : Color("lightGray1"))
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color("navyBlue").opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func emoticon(for emotion: String) -> String {
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
        case "fear": return Color("emeraldGreen")
        case "surprise": return Color.purple
        case "sadness": return Color("skyBlue").opacity(0.8)
        case "disgust": return Color.brown
        case "anger": return Color.red
        case "anticipation": return Color("coralOrange").opacity(0.8)
        default: return Color("navyBlue").opacity(0.6)
        }
    }
    
    private func stressLevelIndicator(_ score: Double) -> Int {
        switch score {
        case 0...3: return 1
        case 4...6: return 2
        case 7...9: return 3
        default: return 1
        }
    }
    
    private func stressColor(_ score: Double) -> Color {
        switch score {
        case 0...3: return Color("emeraldGreen")
        case 4...6: return Color("coralOrange")
        case 7...9: return Color.red
        default: return Color("emeraldGreen")
        }
    }
}

