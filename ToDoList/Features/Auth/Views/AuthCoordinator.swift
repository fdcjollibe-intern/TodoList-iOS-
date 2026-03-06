//
//  AuthCoordinator.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//



import SwiftUI
import FirebaseAuth

@Observable
final class AuthStateManager {
    var isAuthenticated: Bool = false
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Check initial auth state
        isAuthenticated = Auth.auth().currentUser != nil
        
        // Listen for auth state changes
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct AuthCoordinator: View {
    @State private var authStateManager = AuthStateManager()
    
    var body: some View {
        Group {
            if authStateManager.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}


#Preview {
    AuthCoordinator()
}
