////
////  CustomTextField.swift
////  ALP_Jevon_Carry
////
////  Created by Daffa Khoirul on 21/05/25.
////
//
//import SwiftUI
//
//struct CustomTextField: View {
//    let placeholder: String
//    @Binding var text: String
//    
//    var body: some View {
//        TextField(placeholder, text: $text)
//            .padding()
//            
//            .background(Color("lightGray1"))
//            .cornerRadius(8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color("lightGray1"), lineWidth: 1)
//            )
//    }
//}
//
//struct HobbyChip: View {
//    let hobby: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            Text(hobby)
//                .font(.subheadline)
//                .frame(width: 104, height: 36) // Ukuran seragam
//                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
//                .foregroundColor(isSelected ? .white : .primary)
//                .cornerRadius(20)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(isSelected ? Color.blue : Color("lightGray1"), lineWidth: 1)
//                )
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//struct CustomSecureField: View {
//    let placeholder: String
//    @Binding var text: String
//    @State private var isSecure: Bool = true
//    
//    var body: some View {
//        HStack {
//            // Conditional field based on security state
//            if isSecure {
//                SecureField(placeholder, text: $text)
//            } else {
//                TextField(placeholder, text: $text)
//            }
//            
//            // Show/Hide button
//            Button(action: {
//                isSecure.toggle()
//            }) {
//                Image(systemName: isSecure ? "eye" : "eye.slash")
//                    .foregroundColor(.gray)
//            }
//        }
//        .padding()
//        .background(Color("lightGray1"))
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(Color("lightGray1"), lineWidth: 1)
//        )
//    }
//}
//
//
