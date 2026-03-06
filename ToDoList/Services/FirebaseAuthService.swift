// Services/FirebaseAuthService.swift

import Foundation
import FirebaseAuth

/// Actor handling all Firebase Authentication operations
actor FirebaseAuthService {
    // MARK: - Singleton
    
    static let shared = FirebaseAuthService()
    
    private init() {}
    
    // MARK: - Properties
    
    /// Current authenticated user ID
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    /// Current authenticated user email
    var currentUserEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    // MARK: - Authentication Methods
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user.uid
    }
    
    /// Register new user with email and password
    func register(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    /// Sign out current user
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Delete current user account
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUserLoggedIn
        }
        try await user.delete()
    }
    
    /// Send password reset email
    func sendPasswordReset(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Update user email
    func updateEmail(newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUserLoggedIn
        }
        try await user.updateEmail(to: newEmail)
    }
    
    /// Update user password
    func updatePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noUserLoggedIn
        }
        try await user.updatePassword(to: newPassword)
    }
    
    /// Check if user is authenticated
    func isAuthenticated() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case noUserLoggedIn
    case invalidCredentials
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .noUserLoggedIn:
            return "No user is currently logged in"
        case .invalidCredentials:
            return "Invalid email or password"
        case .weakPassword:
            return "Password is too weak. Use at least 6 characters"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .userNotFound:
            return "No account found with this email"
        case .networkError:
            return ErrorMessage.networkError
        case .unknown:
            return ErrorMessage.genericError
        }
    }
    
    static func from(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        guard nsError.domain == AuthErrorDomain else {
            return .unknown
        }
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
             AuthErrorCode.invalidEmail.rawValue:
            return .invalidCredentials
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        default:
            return .unknown
        }
    }
}
