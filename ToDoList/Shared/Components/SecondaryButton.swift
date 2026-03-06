// Shared/Components/SecondaryButton.swift

import SwiftUI

struct SecondaryButton: View {
    // MARK: - Properties
    
    let title: String
    var icon: String?
    var isLoading: Bool
    var isDisabled: Bool
    let action: () -> Void
    
    // MARK: - Init
    
    init(
        title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack(spacing: Spacing.md) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .textPrimary))
                        .scaleEffect(0.9)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Text(title)
                    .font(Typography.buttonLarge)
                    .foregroundStyle(Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.appSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isDisabled || isLoading ? Color.appBorder : Color.textTertiary,
                        lineWidth: 1.5
                    )
            )
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        SecondaryButton(
            title: "Continue with Google",
            icon: "globe"
        ) {
            print("Button tapped")
        }
        
        SecondaryButton(
            title: "Signing In...",
            icon: "globe",
            isLoading: true
        ) {
            print("Button tapped")
        }
        
        SecondaryButton(
            title: "Continue with Google",
            icon: "globe",
            isDisabled: true
        ) {
            print("Button tapped")
        }
    }
    .padding()
    .background(Color.appBackground)
}
