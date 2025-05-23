//
//  CustomTextField.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 21/05/25.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

struct HobbyChip: View {
    let hobby: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(hobby)
                .font(.subheadline)
                .frame(width: 100, height: 36) // Ukuran seragam
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isSelected ? Color.blue : Color(.systemGray3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isSecure: Bool = true
    
    var body: some View {
        HStack {
            // Conditional field based on security state
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            // Show/Hide button
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}
