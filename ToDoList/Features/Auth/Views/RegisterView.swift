// Features/Auth/Views/RegisterView.swift

import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    
    @State private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Form
                    formSection
                    
                    // Actions
                    actionsSection
                    
                    Spacer(minLength: Spacing.xxl)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(Typography.bodyMedium)
                    }
                    .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            // App Icon/Logo
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appSecondary, Color.appTertiary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                )
            
            VStack(spacing: Spacing.xs) {
                Text("Create Account")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Sign up to get started")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: Spacing.lg) {
            // Display Name Field
            InputField(
                label: "Display Name",
                placeholder: "Enter your name",
                text: $viewModel.displayName,
                errorMessage: viewModel.displayNameError,
                autocapitalization: .words
            )
            
            // Email Field
            InputField(
                label: "Email",
                placeholder: "Enter your email",
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            // Password Field
            InputField(
                label: "Password",
                placeholder: "Enter your password",
                text: $viewModel.password,
                isSecure: true,
                errorMessage: viewModel.passwordError
            )
            
            // Confirm Password Field
            InputField(
                label: "Confirm Password",
                placeholder: "Re-enter your password",
                text: $viewModel.confirmPassword,
                isSecure: true,
                errorMessage: viewModel.confirmPasswordError
            )
            
            // Error Message
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
        }
    }
    
    private var actionsSection: some View {
        VStack(spacing: Spacing.lg) {
            // Sign Up Button
            PrimaryButton(
                title: "Sign Up",
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task {
                    await viewModel.register()
                }
            }
            
            // Login Link
            HStack(spacing: Spacing.xs) {
                Text("Already have an account?")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Sign In")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RegisterView()
    }
}
