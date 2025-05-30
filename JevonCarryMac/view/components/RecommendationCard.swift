////
////  RecommendationCard.swift
////  ALP_Jevon_Carry
////
////  Created by Daffa Khoirul on 26/05/25.
////
//
import SwiftUI
// Enhanced RecommendationCardView (assuming it exists)
struct RecommendationCardView: View {
    let activity: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundColor(Color("coralOrange"))
            
            Text(activity)
                .font(.body)
                .foregroundColor(Color("navyBlue"))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(Color("skyBlue"))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color("skyBlue").opacity(0.08), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("lightGray1"), lineWidth: 1)
        )
    }
}

