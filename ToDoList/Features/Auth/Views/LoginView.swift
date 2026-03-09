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
    @State private var rememberMe = false
    @State private var showPassword = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
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
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var topSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Log in to stay on")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("top of your tasks\nand projects.")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
            
            // Illustration placeholder
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, Spacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, 60)
        .padding(.bottom, Spacing.xl)
    }
    
    private var formCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: Spacing.lg) {
                // Title
                VStack(spacing: 4) {
                    Text("Login")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text("Don't Have An Account?")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                        
                        Button("Sign Up") {
                            showRegister = true
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
                
                // Login Button
                Button(action: {
                    Task {
                        await viewModel.signIn()
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
                            await viewModel.signInWithGoogle()
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
            .background(Color.white)
            .cornerRadius(32, corners: [.topLeft, .topRight])
        }
    }
}

// MARK: - Custom Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

//#Preview {
//    LoginView()
//}
//
//                
//                Button(action: {
//                    showRegister = true
//                }) {
//                    Text("Sign Up")
//                        .font(Typography.bodyMedium)
//                        .foregroundStyle(Color.appPrimary)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    LoginView()
//}
