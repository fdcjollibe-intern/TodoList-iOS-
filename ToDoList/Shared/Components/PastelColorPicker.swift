//
//  PastelColorPicker.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct PastelColorPicker: View {
    // MARK: - Properties
    
    @Binding var selectedColor: String
    @Environment(\.dismiss) private var dismiss
    
    private let pastelColors = PastelColors.all
    
    private let columns = [
        GridItem(.adaptive(minimum: 60), spacing: Spacing.lg)
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            Text("Choose Profile Color")
                .font(Typography.title3)
                .foregroundStyle(Color.textPrimary)
            
            // Color Grid
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                ForEach(pastelColors, id: \.self) { color in
                    colorButton(color)
                }
            }
            .padding(.horizontal, Spacing.xl)
            
            // Buttons
            HStack(spacing: Spacing.md) {
                SecondaryButton(title: "Cancel") {
                    dismiss()
                }
                
                PrimaryButton(title: "Select") {
                    dismiss()
                }
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(.vertical, Spacing.xl)
        .background(Color.appSurface)
        .cornerRadius(20)
        .padding(.horizontal, Spacing.xl)
    }
    
    // MARK: - View Components
    
    private func colorButton(_ color: String) -> some View {
        Button(action: {
            selectedColor = color
        }) {
            ZStack {
                Circle()
                    .fill(Color(hex: color))
                    .frame(width: 60, height: 60)
                
                if selectedColor == color {
                    Circle()
                        .stroke(Color.appPrimary, lineWidth: 3)
                        .frame(width: 66, height: 66)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        
        PastelColorPicker(selectedColor: .constant("#DDD6FE"))
    }
}
