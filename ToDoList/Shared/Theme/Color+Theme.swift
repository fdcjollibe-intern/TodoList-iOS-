// Shared/Theme/Color+Theme.swift

import SwiftUI
import UIKit

extension Color {
    // MARK: - Pastel Primary Colors
    
    /// Main accent color - soft purple/lavender
    static let appPrimary = Color(hex: "#A78BFA")
    
    /// Secondary accent - warm coral/salmon
    static let appSecondary = Color(hex: "#FCA5A5")
    
    /// Tertiary accent - soft yellow
    static let appTertiary = Color(hex: "#FDE68A")
    
    /// Success color - medium green
    static let appSuccess = Color(hex: "#22C55E")
    
    /// Warning color - soft orange
    static let appWarning = Color(hex: "#FDBA74")
    
    /// Destructive color - soft red
    static let appDestructive = Color(hex: "#FCA5A5")
    
    // MARK: - Backgrounds
    
    /// Main app background
    static let appBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)  // #1C1C1E
            : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)  // #FAFAFC
    })
    
    /// Card/surface background
    static let appSurface = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)  // #2C2C2E
            : .white
    })
    
    /// Input field background
    static let appInputBackground = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.23, green: 0.23, blue: 0.24, alpha: 1.0)  // #3A3A3C
            : UIColor(red: 0.96, green: 0.96, blue: 0.97, alpha: 1.0)  // #F5F5F7
    })
    
    // MARK: - Text Colors
    
    /// Primary text color
    static let textPrimary = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 1.0)
            : UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)  // #1C1C1E
    })
    
    /// Secondary text color (muted)
    static let textSecondary = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.6, alpha: 1.0)
            : UIColor(red: 0.47, green: 0.47, blue: 0.50, alpha: 1.0)  // #787880
    })
    
    /// Tertiary text color (very muted)
    static let textTertiary = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.4, alpha: 1.0)
            : UIColor(red: 0.68, green: 0.68, blue: 0.70, alpha: 1.0)  // #AEAEB2
    })
    
    // MARK: - Border & Divider Colors
    
    /// Subtle borders
    static let appBorder = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.3, alpha: 0.3)
            : UIColor(red: 0.85, green: 0.85, blue: 0.86, alpha: 1.0)  // #D9D9DB
    })
    
    /// Divider lines
    static let appDivider = Color(uiColor: UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 0.3, alpha: 0.2)
            : UIColor(red: 0.92, green: 0.92, blue: 0.93, alpha: 1.0)  // #EBEBED
    })
    
    // MARK: - Pastel Task Category Colors
    
    static let pastelPurple = Color(hex: "#DDD6FE")
    static let pastelPink = Color(hex: "#FED7D7")
    static let pastelYellow = Color(hex: "#FEF3C7")
    static let pastelBlue = Color(hex: "#DBEAFE")
    static let pastelGreen = Color(hex: "#D1FAE5")
    
    // MARK: - Helper to create Color from hex
    
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
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - Color Palette

struct ColorPalette {
    static let taskColors: [String] = [
        "#DDD6FE",  // Pastel Purple
        "#FED7D7",  // Pastel Pink
        "#FEF3C7",  // Pastel Yellow
        "#DBEAFE",  // Pastel Blue
        "#D1FAE5",  // Pastel Green
        "#FECACA",  // Pastel Red
        "#FED7AA",  // Pastel Orange
        "#E9D5FF",  // Pastel Lavender
        "#BFDBFE",  // Pastel Sky Blue
        "#FCE7F3",  // Pastel Rose
        "#FEF9C3",  // Pastel Lemon
        "#D1D5DB"   // Pastel Gray
    ]
}
