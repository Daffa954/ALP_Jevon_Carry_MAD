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
    @State var isAnalyzed: Bool = true
    @State var userID: String
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "#F5F7FA"), Color(hex: "#F5F7FA").opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [Color(hex: "#498FD0"), Color(hex: "#498FD0").opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color(hex: "#498FD0").opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "book.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 32, weight: .medium))
                            }
                            
                            VStack(spacing: 4) {
                                Text("New Journal Entry")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hex: "#2C3E50"))
                                
                                Text("Share your thoughts and feelings")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#498FD0"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // Writing Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Write your thoughts")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "#2C3E50"))
                                Spacer()
                                
                                // Character counter with better styling
                                Text("\(journalViewModel.userInput.count)/1000")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(characterCountColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(characterCountColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Enhanced text editor
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: Color(hex: "#498FD0").opacity(0.08), radius: 8, x: 0, y: 4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                isEditing ? Color(hex: "#498FD0") : Color(hex: "#F5F7FA"),
                                                lineWidth: isEditing ? 2 : 1
                                            )
                                    )
                                
                                VStack {
                                    if journalViewModel.userInput.isEmpty && !isEditing {
                                        VStack(spacing: 12) {
                                            Image(systemName: "pencil.and.outline")
                                                .font(.system(size: 32))
                                                .foregroundColor(Color(hex: "#498FD0").opacity(0.4))
                                            
                                            Text("Start writing your journal entry...")
                                                .font(.body)
                                                .foregroundColor(Color(hex: "#498FD0").opacity(0.6))
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.top, 80)
                                    }
                                    
                                    TextEditor(text: $journalViewModel.userInput)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.clear)
                                        .font(.body)
                                        .foregroundColor(Color(hex: "#2C3E50"))
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isEditing = true
                                            }
                                        }
                                }
                                .padding(16)
                            }
                            .frame(minHeight: 200, maxHeight: 300)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button("Cancel") {
                                dismiss()
                            }
                            .font(.headline)
                            .foregroundColor(Color(hex: "#F27E63"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#F27E63").opacity(0.1))
                            .cornerRadius(12)
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    journalViewModel.analyzeEmotion(userID: userID)
                                    isAnalyzed = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if journalViewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "brain.head.profile")
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    
                                    Text(journalViewModel.isLoading ? "Analyzing..." : "Save & Analyze")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: journalViewModel.userInput.isEmpty ?
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.3)] :
                                        [Color(hex: "#3DBE8B"), Color(hex: "#3DBE8B").opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(
                                    color: journalViewModel.userInput.isEmpty ?
                                    Color.clear : Color(hex: "#3DBE8B").opacity(0.3),
                                    radius: 6, x: 0, y: 3
                                )
                            }
                            .disabled(journalViewModel.userInput.isEmpty || journalViewModel.isLoading)
                        }
                        
                        // Results Section
                        if isAnalyzed && !journalViewModel.isLoading {
                            VStack(spacing: 20) {
                                if !journalViewModel.result.title.isEmpty {
                                    // Analysis Result
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "brain.head.profile")
                                                .font(.title2)
                                                .foregroundColor(Color(hex: "#498FD0"))
                                            
                                            Text("Analysis Result")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "#2C3E50"))
                                            
                                            Spacer()
                                        }
                                        
                                        ResultCardView(journal: journalViewModel.result)
                                    }
                                    
                                    // Activity Recommendations
                                    VStack(spacing: 16) {
                                        HStack {
                                            Image(systemName: "lightbulb.fill")
                                                .font(.title2)
                                                .foregroundColor(Color(hex: "#F27E63"))
                                            
                                            Text("Recommended Activities")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(hex: "#2C3E50"))
                                            
                                            Spacer()
                                        }
                                        
                                        if let error = journalViewModel.errorMessage {
                                            VStack(spacing: 8) {
                                                Image(systemName: "exclamationmark.triangle")
                                                    .font(.title2)
                                                    .foregroundColor(Color(hex: "#F27E63"))
                                                
                                                Text(error)
                                                    .font(.body)
                                                    .foregroundColor(Color(hex: "#F27E63"))
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                            .background(Color(hex: "#F27E63").opacity(0.1))
                                            .cornerRadius(12)
                                        } else if journalViewModel.recommendations.isEmpty {
                                            VStack(spacing: 8) {
                                                Image(systemName: "hourglass.tophalf.filled")
                                                    .font(.title2)
                                                    .foregroundColor(Color(hex: "#498FD0"))
                                                
                                                Text("No recommendations available yet.")
                                                    .font(.body)
                                                    .foregroundColor(Color(hex: "#498FD0"))
                                            }
                                            .padding()
                                            .background(Color(hex: "#498FD0").opacity(0.1))
                                            .cornerRadius(12)
                                        } else {
                                            LazyVStack(spacing: 12) {
                                                ForEach(journalViewModel.recommendations, id: \.self) { activity in
                                                    RecommendationCardView(activity: activity)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.5), value: journalViewModel.result.title)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isEditing = false
            }
        }
    }
    
    private var characterCountColor: Color {
        if journalViewModel.userInput.count > 1000 {
            return Color(hex: "#F27E63")
        } else if journalViewModel.userInput.count > 800 {
            return Color(hex: "#F27E63").opacity(0.7)
        } else {
            return Color(hex: "#498FD0")
        }
    }
}

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
                    .foregroundColor(Color(hex: "#2C3E50"))
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
                    .foregroundColor(Color(hex: "#498FD0"))
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(hex: "#498FD0").opacity(0.1), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "#F5F7FA"), lineWidth: 1)
        )
    }
    
    private var scoreColor: Color {
        switch journal.score {
        case 0...3: return Color(hex: "#F27E63")
        case 4...6: return Color(hex: "#F27E63").opacity(0.8)
        case 7...10: return Color(hex: "#3DBE8B")
        default: return Color(hex: "#498FD0")
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
        case "joy": return Color(hex: "#3DBE8B")
        case "trust": return Color(hex: "#498FD0")
        case "fear": return Color(hex: "#F27E63")
        case "surprise": return Color(hex: "#498FD0")
        case "sadness": return Color(hex: "#2C3E50")
        case "disgust": return Color(hex: "#F27E63")
        case "anger": return Color(hex: "#F27E63")
        case "anticipation": return Color(hex: "#498FD0")
        default: return Color(hex: "#2C3E50")
        }
    }
}

// Enhanced RecommendationCardView (assuming it exists)
struct RecommendationCardView: View {
    let activity: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundColor(Color(hex: "#F27E63"))
            
            Text(activity)
                .font(.body)
                .foregroundColor(Color(hex: "#2C3E50"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color(hex: "#498FD0"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color(hex: "#498FD0").opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#F5F7FA"), lineWidth: 1)
        )
    }
}

// MARK: - Color Extension (if not already added)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    NavigationStack {
        AddJournalView(isAddJournal: .constant(true), userID: "fBdMKF5GIvMuufer7JqzgPgVwEI2")
            .environmentObject(JournalViewModel())
    }
}
