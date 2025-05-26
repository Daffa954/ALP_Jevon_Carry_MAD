//
//  RecommendationCard.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 26/05/25.
//

import SwiftUI


struct RecommendationCardView: View {
    let activity: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 24))
            
            Text(activity)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color.white)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}


#Preview {
    RecommendationCardView(activity: "hello")
}
