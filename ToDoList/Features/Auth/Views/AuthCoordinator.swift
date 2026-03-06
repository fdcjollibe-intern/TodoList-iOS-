// Features/Auth/Views/AuthCoordinator.swift

import SwiftUI
import FirebaseAuth

@Observable
final class AuthStateManager {
    var isAuthenticated: Bool = false
    
    init() {
        // Check initial auth state
        isAuthenticated = Auth.auth().currentUser != nil
        
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
            }
        }
    }
}

struct AuthCoordinator: View {
    @State private var authStateManager = AuthStateManager()
    
    var body: some View {
        Group {
            if authStateManager.isAuthenticated {
                // ⚠️ TODO: Replace with actual HomeView once implemented
                PlaceholderHomeView()
            } else {
                LoginView()
            }
        }
    }
}

// MARK: - Placeholder Home View

private struct PlaceholderHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                VStack(spacing: Spacing.xl) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.appPrimary)
                    
                    VStack(spacing: Spacing.sm) {
                        Text("You're Logged In!")
                            .font(Typography.largeTitle)
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Home screen coming soon...")
                            .font(Typography.bodyRegular)
                            .foregroundStyle(Color.textSecondary)
                    }
                    
                    PrimaryButton(title: "Sign Out") {
                        Task {
                            try? await FirebaseAuthService.shared.signOut()
                        }
                    }
                    .padding(.horizontal, Spacing.xl)
                    .padding(.top, Spacing.xl)
                }
            }
            .navigationTitle("Home")
        }
    }
}

// MARK: - Preview

#Preview {
    AuthCoordinator()
}
