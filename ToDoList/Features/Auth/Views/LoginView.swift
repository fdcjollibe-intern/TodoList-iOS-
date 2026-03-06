//
//  LoginView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//



import SwiftUI

struct LoginView: View {
    // MARK: - Properties
    
    @State private var viewModel = LoginViewModel()
    @State private var showRegister = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
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
                    .padding(.top, Spacing.huge)
                }
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
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
                        colors: [Color.appPrimary, Color.appSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                )
            
            VStack(spacing: Spacing.xs) {
                Text("Welcome Back")
                    .font(Typography.largeTitle)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Sign in to continue")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
    
    private var formSection: some View {
        VStack(spacing: Spacing.lg) {
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
            // Sign In Button
            PrimaryButton(
                title: "Sign In",
                isLoading: viewModel.isLoading,
                isDisabled: !viewModel.isFormValid
            ) {
                Task {
                    await viewModel.signIn()
                }
            }
            
            // Divider
            DividerWithText(text: "or")
            
            // Google Sign In Button
            SecondaryButton(
                title: "Continue with Google",
                icon: "globe",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.signInWithGoogle()
                }
            }
            
            // Register Link
            HStack(spacing: Spacing.xs) {
                Text("Don't have an account?")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                
                Button(action: {
                    showRegister = true
                }) {
                    Text("Sign Up")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
