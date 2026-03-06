// Shared/Components/CategoryChip.swift

import SwiftUI

struct CategoryChip: View {
    // MARK: - Properties
    
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    // MARK: - Init
    
    init(
        title: String,
        count: Int? = nil,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.count = count
        self.isSelected = isSelected
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Text(title)
                    .font(Typography.bodyMedium)
                
                if let count = count {
                    Text("(\(count))")
                        .font(Typography.bodyRegular)
                }
            }
            .foregroundStyle(isSelected ? Color.textPrimary : Color.textSecondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(
                isSelected ? Color.appSurface : Color.clear
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.clear : Color.appBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: Spacing.md) {
        CategoryChip(title: "All", count: 52, isSelected: true) {}
        CategoryChip(title: "UI/UX", count: 16, isSelected: false) {}
        CategoryChip(title: "Lifestyle", count: 3, isSelected: false) {}
    }
    .padding()
    .background(Color.appBackground)
}
