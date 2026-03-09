//
//  AuthStateManager.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/9/26.
//

import Foundation
import Observation
import FirebaseAuth

@Observable
final class AuthStateManager {
    var isAuthenticated: Bool = false
    var isLoading: Bool = true
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Check initial auth state from UserDefaults and Firebase
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        isAuthenticated = isLoggedIn && Auth.auth().currentUser != nil
        
        // Listen for auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                // Update UserDefaults when auth state changes
                if user == nil {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.removeObject(forKey: "userId")
                    UserDefaults.standard.synchronize()
                }
            }
        }
        
        // Show splash screen
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
