//
//  ColorPickerSheet.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct ColorPickerSheet: View {
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedColor: String
    
    private let colors: [String] = [
        "#DDD6FE", // Lavender
        "#FED7D7", // Coral
        "#FEF3C7", // Yellow
        "#D1FAE5", // Mint
        "#BFDBFE", // Sky
        "#FED7AA", // Peach
        "#FECACA", // Pink
        "#E9D5FF", // Purple
        "#BAE6FD", // Light Blue
        "#D9F99D", // Lime
        "#FDE68A", // Gold
        "#F3E8FF"  // Lilac
    ]
    
    private let columns = [
        GridItem(.adaptive(minimum: 70))
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Selected Color Preview
                    VStack(spacing: Spacing.md) {
                        Text("Selected Color")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.textSecondary)
                        
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: selectedColor))
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.appBorder, lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, Spacing.xl)
                    
                    Divider()
                        .padding(.vertical, Spacing.sm)
                    
                    // Color Grid
                    LazyVGrid(columns: columns, spacing: Spacing.lg) {
                        ForEach(colors, id: \.self) { color in
                            ColorCell(
                                color: color,
                                isSelected: selectedColor == color
                            ) {
                                selectedColor = color
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(Color.appBackground)
            .navigationTitle("Choose Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

// MARK: - Color Cell

struct ColorCell: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    init(color: String, isSelected: Bool, action: @escaping () -> Void) {
        self.color = color
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: color))
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.appPrimary : Color.appBorder, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ColorPickerSheet(selectedColor: .constant("#DDD6FE"))
}
