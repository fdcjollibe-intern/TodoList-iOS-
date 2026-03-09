//
//  AuthCoordinator.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct AuthCoordinator: View {
    @State private var authStateManager = AuthStateManager()
    
    var body: some View {
        Group {
            if authStateManager.isLoading {
                SplashScreenView()
            } else if authStateManager.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    AuthCoordinator()
}
