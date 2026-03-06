// Shared/Components/DividerWithText.swift

import SwiftUI

struct DividerWithText: View {
    let text: String
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Rectangle()
                .fill(Color.appDivider)
                .frame(height: 1)
            
            Text(text)
                .font(Typography.caption)
                .foregroundStyle(Color.textTertiary)
            
            Rectangle()
                .fill(Color.appDivider)
                .frame(height: 1)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
        DividerWithText(text: "or")
        DividerWithText(text: "OR")
    }
    .padding()
    .background(Color.appBackground)
}
