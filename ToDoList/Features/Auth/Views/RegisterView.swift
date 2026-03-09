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
        VStack(alignment: .leading, spacing: 12) {
            // Back Button
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Create Your Account")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                
                Text("and Simplify Your Workday")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
    
    private var formCard: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .bottom)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                // Title
                VStack(spacing: 8) {
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
                .padding(.top, 24)
                
                // Display Name Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 20)
                        
                        TextField("Display name", text: $viewModel.displayName)
                            .font(.system(size: 15))
                            .autocapitalization(.words)
                    }
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // First Name and Last Name Row
                HStack(spacing: 12) {
                    // First Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.text.rectangle")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 20)
                            
                            TextField("First name", text: $viewModel.firstName)
                                .font(.system(size: 15))
                                .autocapitalization(.words)
                        }
                        .padding(16)
                        .background(Color.appInputBackground)
                        .cornerRadius(12)
                    }
                    
                    // Last Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: "person.text.rectangle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(Color.textSecondary)
                                .frame(width: 20)
                            
                            TextField("Last name", text: $viewModel.lastName)
                                .font(.system(size: 15))
                                .autocapitalization(.words)
                        }
                        .padding(16)
                        .background(Color.appInputBackground)
                        .cornerRadius(12)
                    }
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 20)
                        
                        TextField("Enter your email address", text: $viewModel.email)
                            .font(.system(size: 15))
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
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
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // Confirm Password Field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
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
                    .padding(16)
                    .background(Color.appInputBackground)
                    .cornerRadius(12)
                }
                
                // Remember Me & Forgot Password
                HStack {
                    Button(action: { rememberMe.toggle() }) {
                        HStack(spacing: 8) {
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
                .padding(.top, 4)
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14))
                        Text(errorMessage)
                            .font(.system(size: 13))
                    }
                    .foregroundStyle(Color.appDestructive)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.appDestructive.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Sign Up Button
                Button(action: {
                    Task {
                        await viewModel.register()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Sign Up")
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
                .padding(.top, 4)
                
                // Divider
                HStack(spacing: 16) {
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
                .padding(.vertical, 8)
                
                // Social Sign In Buttons
                HStack(spacing: 16) {
                    // Apple Button
                    Button(action: {
                        // Handle Apple sign in
                    }) {
                        HStack(spacing: 8) {
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
                        HStack(spacing: 8) {
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
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .cornerRadius(32, corners: [.topLeft, .topRight])
        .clipped()
        }
    }
}

#Preview {
    RegisterView()
}
