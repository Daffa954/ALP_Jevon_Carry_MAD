//
//  JournalCardView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 24/05/25.
//



import SwiftUI

struct JournalCardView: View {
    var journal: JournalModel

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(journal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(emoticon(for: journal.emotion))
                    .font(.largeTitle)
            }

            Text(formattedDate(journal.date))
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(journal.description)
                .font(.body)
                .lineLimit(1)
                    
                

            Text("Emotion: \(journal.emotion)")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
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
}

#Preview {
    JournalCardView(journal: JournalModel(title: "This Week", date: Date(), description: "Test Description stuff sssssssssssssss Test Description stuff sssssssssssssss Test Description stuff sssssssssssssss", emotion: "joy", score: 0))
}
