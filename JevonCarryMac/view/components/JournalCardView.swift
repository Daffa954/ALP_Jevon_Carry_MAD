// JournalCardView.swift
import SwiftUI

struct JournalCardView: View {
    var journal: JournalModel

   
    @Environment(\.colorScheme) var colorScheme // Dapatkan skema warna saat ini

    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Increased spacing for more breathing room
            HStack {
                Text(journal.title)
                    .font(.title) // Slightly larger and bolder for more prominence
                    .fontWeight(.semibold)
                    .foregroundColor(Color("navyBlue")) // Navy Blue for strong title
                
                Spacer()
                
                Text(emoticon(for: journal.emotion))
                    .font(.largeTitle) // Maintain large size for emoticon
                    .scaleEffect(1.1) // Slightly larger emoticon for more impact
            }
            .padding(.bottom, 2) // Little extra space after title/emoticon

            Text(formattedDate(journal.date))
                .font(.callout) // Slightly larger than subheadline, less prominent than title
                .foregroundColor(Color.black) // System secondary: adapts beautifully for light/dark mode
                // Removed padding(.bottom, 2) as VStack spacing handles it better
            
            // Separator for better visual separation
            Divider()
                .background(Color.primary.opacity(0.1)) // Subtle divider, adapts to light/dark
                .padding(.vertical, 5) // Padding around the divider

            Text(journal.description)
                .font(.body)
                .lineLimit(3) // Allow up to 3 lines for more content display
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap vertically without cutting off
                .foregroundColor(Color.black) // System primary: adapts for light/dark mode
                    
            // Emotion tag with a subtle capsule shape
            Text("Emotion: \(journal.emotion.capitalized)")
                .font(.caption)
                .fontWeight(.medium) // Slightly bolder font for the tag
                .foregroundColor(Color.yellow.opacity(2))
                .padding(.vertical, 6) // Increased vertical padding
                .padding(.horizontal, 12) // Increased horizontal padding
                .background(Color("lightGray1").opacity(0.15)) // Slightly stronger background tint
                .cornerRadius(20) // More rounded, capsule-like corners
                .padding(.top, 5) // Push the tag down slightly
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20) // Increased overall card padding
        
        // Adaptive background using Material for elegance and macOS feel
        .background(Color("skyBlue").opacity(0.9)) // Provides a frosted glass effect that adapts automatically
        // Alternatif jika Material tidak disukai:
        // .background(colorScheme == .dark ? Color.black.opacity(0.4) : Color.white)
        
        .cornerRadius(18) // More rounded corners for a softer look
        
        // Adaptive shadow
        .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 4) // Softer, more
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
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


