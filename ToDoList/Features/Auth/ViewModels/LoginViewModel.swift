// Features/Auth/ViewModels/LoginViewModel.swift

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
    
    // MARK: - Mock Factory
    
    static func mock() -> LoginViewModel {
        let viewModel = LoginViewModel()
        viewModel.email = "test@example.com"
        return viewModel
    }
}
