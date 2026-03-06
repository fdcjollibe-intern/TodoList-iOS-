// Shared/Components/InputField.swift

import SwiftUI

struct InputField: View {
    // MARK: - Properties
    
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var errorMessage: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never
    
    @State private var isSecureVisible: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .font(Typography.captionMedium)
                    .foregroundStyle(Color.textSecondary)
            }
            
            // Input Field
            HStack(spacing: Spacing.md) {
                if isSecure && !isSecureVisible {
                    SecureField(placeholder, text: $text)
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textPrimary)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                } else {
                    TextField(placeholder, text: $text)
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textPrimary)
                        .textInputAutocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                }
                
                // Secure toggle button
                if isSecure {
                    Button(action: { isSecureVisible.toggle() }) {
                        Image(systemName: isSecureVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            }
            .padding(Spacing.lg)
            .background(Color.appInputBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(errorMessage != nil ? Color.appDestructive : Color.clear, lineWidth: 1)
            )
            
            // Error Message
            if let errorMessage = errorMessage {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(errorMessage)
                        .font(Typography.footnote)
                }
                .foregroundStyle(Color.appDestructive)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
        InputField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant("")
        )
        
        InputField(
            label: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true
        )
        
        InputField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant("invalid"),
            errorMessage: "Please enter a valid email address"
        )
    }
    .padding()
    .background(Color.appBackground)
}
