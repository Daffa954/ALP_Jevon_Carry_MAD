//
//  HomeView.swift
//  ALP_Jevon_Carry
//
//  Created by Daffa Khoirul on 20/05/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HomeView: View { // Renamed from ContentView to HomeView

    // Placeholder for Image1 if it's not in your assets
    var headerImage: Image {
        // For this example, let's assume "Image1" exists.
        return Image("Image1") // Make sure "Image1" is in your Assets.xcassets
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Header Section
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hi Dave!")
                            .font(.system(size: 30, weight: .bold))
                        Text("Your journey matters.\nLet's see how you're growing.")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    headerImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding(.trailing, 10)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 25)
                .background(Color("color1")) // Use Color1 from Assets
                .clipShape(RoundedCorner(radius: 30, corners: [.bottomLeft, .bottomRight]))

                // MARK: - Main Content Area (White Background)
                VStack(alignment: .leading, spacing: 25) {
                    
                    // MARK: - Your Fresh Start Section
                    VStack(alignment: .center, spacing: 10) {
                        Text("Your Fresh Start")
                            .font(.system(size: 24, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Welcome! Let's grow together,\none day at a time.")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.systemGray5))
                                .frame(height: 180)
                            
                            Text("Overall Graph")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(UIColor.darkGray))
                        }
                    }
                    .padding(.top, 30)

                    // MARK: - Let See Others Result Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Lets See Others Result")
                            .font(.system(size: 22, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 10)

                        ResultCard(title: "Daily Mood", themeColor: Color("color1"))
                        ResultCard(title: "Mood Analysis", themeColor: Color("color1"))
                        ResultCard(title: "Journaling", themeColor: Color("color1"))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .background(Color.white)
                
            } // End of main VStack
        } // End of ScrollView
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: - Reusable Card View
struct ResultCard: View {
    let title: String
    let themeColor: Color

    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemGray5))
                    .frame(height: 130)
                
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(UIColor.darkGray))
            }
            
            Button(action: {
                print("\(title) - See Detail tapped")
                // Add navigation or action here
            }) {
                Text("See Detail")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(themeColor)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider { // Renamed preview provider
    static var previews: some View {
        HomeView() // Preview HomeView
            // Make sure "Color1" and "Image1" are available to your preview target
            // or the preview might show missing asset colors/placeholders.
    }
}
