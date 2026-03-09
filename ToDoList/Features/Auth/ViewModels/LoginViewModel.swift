//
//  LoginViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//


import Foundation
import Observation

@Observable
final class LoginViewModel {
    // MARK: - Published State
    
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isAuthenticated: Bool = false
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        email.trimmed.isValidEmail && password.isValidPassword
    }
    
    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return email.trimmed.isValidEmail ? nil : ErrorMessage.invalidEmail
    }
    
    var passwordError: String? {
        guard !password.isEmpty else { return nil }
        return password.isValidPassword ? nil : ErrorMessage.invalidPassword
    }
    
    // MARK: - Dependencies
    
    private let authService = FirebaseAuthService.shared
    private let databaseService = RealtimeDatabaseService.shared
    
    // MARK: - Actions
    
    func signIn() async {
        guard isFormValid else {
            errorMessage = "Please correct the errors before continuing"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await authService.signIn(email: email.trimmed, password: password)
            
            // Update last login timestamp
            let timestamp = Date().timeIntervalSince1970
            try await databaseService.updateValues(
                ["lastLoginAt": timestamp],
                at: "\(DBPath.users)/\(userId)"
            )
            
            // Save login state to UserDefaults
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.synchronize()
            
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
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await authService.signInWithGoogle()
            
            // Check if user exists in database, if not create profile
            do {
                _ = try await databaseService.fetchUser(userId: userId)
            } catch {
                // User doesn't exist, create profile
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
            
            // Save login state to UserDefaults
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(userId, forKey: "userId")
            UserDefaults.standard.synchronize()
            
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = AuthError.from(error).errorDescription ?? ErrorMessage.genericError
        }
    }
    
    // MARK: - Mock Factory
    
    static func mock() -> LoginViewModel {
        let viewModel = LoginViewModel()
        viewModel.email = "test@example.com"
        return viewModel
    }
}
