//
//  RegisterView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    
    @State private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var rememberMe = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Turquoise Background
            LinearGradient(
                colors: [
                    Color(hex: "#4ECDC4"),
                    Color(hex: "#44A08D")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Section with Title
                topSection
                
                // White Card with Form
                formCard
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - View Components
    
    private var topSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            }
            .padding(.bottom, Spacing.sm)
            
            Text("Create Your Account")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("and Simplify Your\nWorkday")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            // Illustration placeholder
            Image(systemName: "person.crop.circle.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, Spacing.md)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, 60)
        .padding(.bottom, Spacing.lg)
    }
    
    private var formCard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                // Title
                VStack(spacing: 4) {
                    Text("Sign up")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text("Already Have An Account?")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                        
                        Button("Sign In") {
                            dismiss()
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(hex: "#4ECDC4"))
                    }
                }
                .padding(.top, Spacing.xl)
                
                // Email Field
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 20)
                        
                        TextField("Enter your email address", text: $viewModel.email)
                            .font(.system(size: 15))
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding(Spacing.md)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                .padding(.top, Spacing.md)
                
                // Password Field
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "lock")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 20)
                        
                        if showPassword {
                            TextField("Password", text: $viewModel.password)
                                .font(.system(size: 15))
                        } else {
                            SecureField("Password", text: $viewModel.password)
                                .font(.system(size: 15))
                        }
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding(Spacing.md)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 20)
                        
                        if showConfirmPassword {
                            TextField("Confirm Password", text: $viewModel.confirmPassword)
                                .font(.system(size: 15))
                        } else {
                            SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                .font(.system(size: 15))
                        }
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    .padding(Spacing.md)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // Remember Me & Forgot Password
                HStack {
                    Button(action: { rememberMe.toggle() }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .font(.system(size: 18))
                                .foregroundStyle(rememberMe ? Color(hex: "#4ECDC4") : Color.textSecondary)
                            
                            Text("Remember Me")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "#4ECDC4"))
                }
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                        Text(errorMessage)
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(Color.appDestructive)
                    .padding(Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appDestructive.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Sign Up Button (changed from Login to match design)
                Button(action: {
                    Task {
                        await viewModel.register()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .foregroundStyle(.white)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#4ECDC4"),
                            Color(hex: "#44A08D")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
                .opacity(viewModel.isFormValid ? 1 : 0.6)
                
                // Divider
                HStack(spacing: Spacing.md) {
                    Rectangle()
                        .fill(Color.appDivider)
                        .frame(height: 1)
                    
                    Text("Or Continue With")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                    
                    Rectangle()
                        .fill(Color.appDivider)
                        .frame(height: 1)
                }
                .padding(.vertical, Spacing.sm)
                
                // Social Sign In Buttons
                HStack(spacing: Spacing.md) {
                    // Apple Button
                    Button(action: {
                        // Handle Apple sign in
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 18))
                            Text("Apple")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                    
                    // Google Button
                    Button(action: {
                        Task {
                            await viewModel.signUpWithGoogle()
                        }
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "globe")
                                .font(.system(size: 18))
                            Text("Google")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundStyle(Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                    }
                }
                .padding(.bottom, Spacing.xl)
            }
            .padding(.horizontal, Spacing.xl)
        }
        .background(Color.white)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

#Preview {
    RegisterView()
}
