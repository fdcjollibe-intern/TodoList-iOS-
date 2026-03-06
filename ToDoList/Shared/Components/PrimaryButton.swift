// Shared/Components/PrimaryButton.swift

import SwiftUI

struct PrimaryButton: View {
    // MARK: - Properties
    
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        Button(action: {
            if !isLoading && !isDisabled {
                action()
            }
        }) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                
                Text(title)
                    .font(Typography.buttonLarge)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isDisabled || isLoading
                    ? Color.textTertiary
                    : Color.appPrimary
            )
            .cornerRadius(12)
        }
        .disabled(isDisabled || isLoading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        PrimaryButton(title: "Sign In") {
            print("Button tapped")
        }
        
        PrimaryButton(title: "Signing In...", isLoading: true) {
            print("Button tapped")
        }
        
        PrimaryButton(title: "Sign In", isDisabled: true) {
            print("Button tapped")
        }
    }
    .padding()
    .background(Color.appBackground)
}
