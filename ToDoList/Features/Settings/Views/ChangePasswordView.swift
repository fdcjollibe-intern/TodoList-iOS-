//
//  ChangePasswordView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct ChangePasswordView: View {
    // MARK: - Properties
    
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header Description
                    Text("Enter your current password and choose a new one")
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, Spacing.lg)
                    
                    // Form Fields
                    VStack(spacing: Spacing.lg) {
                        // Current Password
                        InputField(
                            label: "Current Password",
                            placeholder: "Enter current password",
                            text: $viewModel.currentPassword,
                            isSecure: true,
                            errorMessage: viewModel.currentPasswordError
                        )
                        
                        // New Password
                        InputField(
                            label: "New Password",
                            placeholder: "Enter new password",
                            text: $viewModel.newPassword,
                            isSecure: true,
                            errorMessage: viewModel.newPasswordError
                        )
                        
                        // Password Strength Indicator
                        if !viewModel.newPassword.isEmpty {
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: viewModel.newPassword.isStrongPassword ? "checkmark.circle.fill" : "info.circle.fill")
                                    .font(.system(size: 14))
                                Text(viewModel.newPassword.passwordStrengthMessage)
                                    .font(Typography.caption)
                            }
                            .foregroundStyle(viewModel.newPassword.isStrongPassword ? Color.appSuccess : Color.appWarning)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Confirm New Password
                        InputField(
                            label: "Confirm New Password",
                            placeholder: "Re-enter new password",
                            text: $viewModel.confirmNewPassword,
                            isSecure: true,
                            errorMessage: viewModel.confirmNewPasswordError
                        )
                    }
                    .padding(Spacing.lg)
                    .background(Color.appSurface)
                    .cornerRadius(16)
                    
                    // Error/Success Messages
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                            Text(errorMessage)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.appDestructive)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appDestructive.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if let successMessage = viewModel.successMessage {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text(successMessage)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.appSuccess)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSuccess.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Save Button
                    PrimaryButton(
                        title: "Change Password",
                        isLoading: viewModel.isLoading,
                        isDisabled: !viewModel.isChangePasswordValid
                    ) {
                        Task {
                            await viewModel.changePassword()
                        }
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .navigationTitle("Change Password")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .onAppear {
            viewModel.clearMessages()
            viewModel.currentPassword = ""
            viewModel.newPassword = ""
            viewModel.confirmNewPassword = ""
            viewModel.currentPasswordError = nil
            viewModel.newPasswordError = nil
            viewModel.confirmNewPasswordError = nil
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChangePasswordView(viewModel: SettingsViewModel())
    }
}
