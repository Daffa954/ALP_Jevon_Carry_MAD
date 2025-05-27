//
//  AppColors.swift
//  ALP_Jevon_Carry
//
//  Created by student on 27/05/25.
//

// Colors.swift (Create this new file or add to an existing utility file)
// Colors.swift
import SwiftUI

struct AppColors {
    // Assuming these are defined as Color Sets in your Assets.xcassets
    // If not, define them here, e.g., Color(red: R/255, green: G/255, blue: B/255)
    static let accent = Color("AccentColor")        // Main accent (e.g., your primary brand color)
    static let background = Color("blackCustom")    // Dark background (if used)
    static let primaryText = Color.white            // For text on dark backgrounds
    static let secondaryText = Color("lightGray1")  // Lighter gray for less important text on dark backgrounds

    // For light backgrounds (like white)
    static let lightPrimaryText = Color.black
    static let lightSecondaryText = Color.gray

    static let inhaleColor = Color("color1")        // Blueish for inhale (used on both light/dark)
    static let exhaleColor = Color("coralOrange")   // Orange for exhale (used on both light/dark)
    static let neutralColor = Color("skyBlue")      // For UI elements like buttons, sliders (used on both)

    static let sessionListBackground = Color("navyBlue").opacity(0.3) // For list items on dark background
    // For list items on white background, you might use Color.white or a very light gray.
    static let lightSessionListRowBackground = Color.white // Or Color(UIColor.systemGray6)
}
