//
//  AddJournalView.swift
//  ALP_Jevon_Carry
//
//  Created by student on 23/05/25.
//

import SwiftUI

struct AddJournalView: View {
    @State private var journalText = ""
    @Binding var isAddJournal: Bool
    @State private var isEditing = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        
        VStack() {
            // Header with icon
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 28))
                
                Text("New Journal Entry")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.semibold)
                Spacer()
            }
            
            
            
            VStack() {
                

                    TextEditor(text: $journalText)
                        .frame(minHeight: 200,maxHeight: 300)
                    
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
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
                Text("\(journalText.count)/1000")
                    .font(.caption)
                    .foregroundColor(journalText.count > 1000 ? .red : .gray)
            }.padding(.bottom, 30)
            
            // Save Button
            HStack{
                Button("Cancel") {
                    dismiss()
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
                
                Button(action: saveEntry) {
                    HStack {
                        
                        Text("Save and Analyze")
                            .font(.headline)
                        
                        
                    }
                    
                    
                }
                .buttonStyle(.borderedProminent)
                .disabled(journalText.isEmpty)
            }
            Spacer()
            
        }
        .padding(.horizontal, 25)
        
    }
    
    private func saveEntry() {
        // Add save functionality here
        print("Saving journal entry: \(journalText)")
        isAddJournal = false
    }
}

//struct AddJournalView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            AddJournalView(isAddJournal: .constant(true))
//        }
//    }
//}

#Preview {
    NavigationStack {
        AddJournalView(isAddJournal: .constant(true))
        
    }
}
