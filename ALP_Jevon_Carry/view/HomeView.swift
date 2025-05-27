import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct HomeView: View {

    var headerImage: Image {
        return Image("Image1")
    }
    
    let cornerRadius: CGFloat = 30 // Define corner radius for consistency
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        
        ZStack { // << --- Root ZStack for global background
            // Bottom layer: Global background color
            Color("color1")
                .edgesIgnoringSafeArea(.all)

            // Top layer: Your scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) { // No spacing between blue and white visually
                    
                    // MARK: - Header Section
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Hi \(authVM.user?.email ?? "User")")
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
                    .padding(.top, 70)
                    .padding(.bottom, 32)
                    .padding(.horizontal, 20)
                    .background(Color("color1")) // This header will blend with the ZStack background
                    // No clipShape on blue header means square bottom corners

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
                        // Adjusted top padding for direct spacing, no overlap
                        .padding(.top, 25)

                        // MARK: - Let See Others Result Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Take a Quiz")
                                .font(.system(size: 22, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 10)

                            ResultCard(title: "Daily Mood", themeColor: Color("color1"))
                            ResultCard(title: "Daily Mood", themeColor: Color("color1"))
                            
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 20)
                    .background(Color.white)
                    .frame(minHeight: UIScreen.main.bounds.height)
                    .clipShape(RoundedCorner(radius: cornerRadius, corners: .allCorners))
                    // No .offset() here, so it sits directly below the blue header
                    
                } // End of main content VStack inside ScrollView
            } // End of ScrollView
            // .background(...) removed from ScrollView
            .edgesIgnoringSafeArea(.top) // Allows ScrollView content (blue header) to go to top edge
        }
    }
}

// MARK: - Reusable Card View (identical to before)
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
            
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
