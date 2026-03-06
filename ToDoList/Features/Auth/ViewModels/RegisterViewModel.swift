//
//  RegisterViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import Foundation
import Observation

@Observable
final class RegisterViewModel {
    // MARK: - Published State
    
    var displayName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isAuthenticated: Bool = false
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        displayName.trimmed.isNotEmpty &&
        email.trimmed.isValidEmail &&
        password.isValidPassword &&
        password == confirmPassword
    }
    
    var displayNameError: String? {
        guard !displayName.isEmpty else { return nil }
        return displayName.trimmed.isNotEmpty ? nil : ErrorMessage.emptyField
    }
    
    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return email.trimmed.isValidEmail ? nil : ErrorMessage.invalidEmail
    }
    
    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        return password.isValidPassword ? nil : ErrorMessage.invalidPassword
    }
    
    var confirmPasswordError: String? {
        guard !confirmPassword.isEmpty else { return nil }
        return password == confirmPassword ? nil : ErrorMessage.passwordMismatch
    }
    
    // MARK: - Dependencies
    
    private let authService = FirebaseAuthService.shared
    private let databaseService = RealtimeDatabaseService.shared
    
    // MARK: - Actions
    
    func register() async {
        guard isFormValid else {
            errorMessage = "Please correct the errors before continuing"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Create auth account
            let userId = try await authService.register(email: email.trimmed, password: password)
            
            // Create user in database
            let timestamp = Date().timeIntervalSince1970
            let user = User(
                id: userId,
                email: email.trimmed,
                displayName: displayName.trimmed,
                createdAt: timestamp,
                lastLoginAt: timestamp
            )
            try await databaseService.saveUser(user)
            
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = AuthError.from(error).errorDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    @MainActor
    func signUpWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await authService.signInWithGoogle()
            
            // Check if user exists in database, if not create profile
            do {
                _ = try await databaseService.fetchUser(userId: userId)
            } catch {
                // User doesn't exist, create profile from Google account
                if let email = await authService.currentUserEmail {
                    let timestamp = Date().timeIntervalSince1970
                    let displayName = email.components(separatedBy: "@").first ?? "User"
                    let user = User(
                        id: userId,
                        email: email,
                        displayName: displayName,
                        createdAt: timestamp,
                        lastLoginAt: timestamp
                    )
                    try await databaseService.saveUser(user)
                }
            }
            
            // Update last login timestamp
            let timestamp = Date().timeIntervalSince1970
            try await databaseService.updateValues(
                ["lastLoginAt": timestamp],
                at: "\(DBPath.users)/\(userId)"
            )
            
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = AuthError.from(error).errorDescription ?? ErrorMessage.genericError
        }
    }
    
    // MARK: - Mock Factory
    
    static func mock() -> RegisterViewModel {
        let viewModel = RegisterViewModel()
        viewModel.displayName = "John Doe"
        viewModel.email = "john@example.com"
        return viewModel
    }
}
