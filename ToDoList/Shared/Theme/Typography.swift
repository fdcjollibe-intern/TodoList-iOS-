// Shared/Theme/Typography.swift

import SwiftUI

enum Typography {
    // MARK: - Headings
    
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .semibold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // MARK: - Body
    
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyRegular = Font.system(size: 15, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .medium)
    static let bodySemibold = Font.system(size: 15, weight: .semibold)
    
    // MARK: - Small Text
    
    static let caption = Font.system(size: 13, weight: .regular)
    static let captionMedium = Font.system(size: 13, weight: .medium)
    static let footnote = Font.system(size: 12, weight: .regular)
    
    // MARK: - Buttons
    
    static let buttonLarge = Font.system(size: 17, weight: .semibold)
    static let buttonMedium = Font.system(size: 15, weight: .semibold)
    static let buttonSmall = Font.system(size: 13, weight: .semibold)
}
