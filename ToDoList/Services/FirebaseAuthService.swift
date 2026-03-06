//
//  FirebaseAuthService.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//


import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

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
    
    /// Sign in with Google
    @MainActor
    func signInWithGoogle() async throws -> String {
        
        throw AuthError.googleSignInNotConfigured
        
        /*
        // Get the client ID from Firebase configuration
        guard let clientID = Auth.auth().app?.options.clientID else {
            throw AuthError.unknown
        }
        
        // Configure Google Sign In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Get the presenting view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.unknown
        }
        
        // Perform Google Sign In
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredentials
        }
        
        let accessToken = result.user.accessToken.tokenString
        
        // Create Firebase credential
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        // Sign in to Firebase
        let authResult = try await Auth.auth().signIn(with: credential)
        return authResult.user.uid
        */
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
        
        // Use the new Firebase API: Send verification email before updating
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
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
    case googleSignInNotConfigured
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
        case .googleSignInNotConfigured:
            return "Google Sign-In is not configured yet. Please use email/password to sign in."
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

