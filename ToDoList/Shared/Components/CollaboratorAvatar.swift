//
//  CollaboratorAvatar.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/9/26.
//

import SwiftUI

struct CollaboratorAvatar: View {
    let email: String
    let size: CGFloat
    
    @State private var user: User?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let user = user, let profilePhoto = user.profilePhoto, profilePhoto.hasPrefix("http") {
                // Show profile photo
                AsyncImage(url: URL(string: profilePhoto)) { phase in
                    switch phase {
                    case .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure:
                        // Fallback to initials
                        initialsCircle
                    @unknown default:
                        initialsCircle
                    }
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
            } else {
                // Show colored circle with initials
                initialsCircle
            }
        }
        .task {
            await loadUser()
        }
    }
    
    private var initialsCircle: some View {
        Circle()
            .fill(getCollaboratorColor(email: email))
            .frame(width: size, height: size)
            .overlay(
                Text(getCollaboratorInitials(email: email))
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
    
    private func loadUser() async {
        do {
            user = try await RealtimeDatabaseService.shared.fetchUserByEmail(email)
            isLoading = false
        } catch {
            print("Failed to load user for email \(email): \(error)")
            isLoading = false
        }
    }
    
    private func getCollaboratorInitials(email: String) -> String {
        let username = email.components(separatedBy: "@").first ?? email
        let components = username.components(separatedBy: ".")
        if components.count > 1 {
            let first = String(components[0].prefix(1)).uppercased()
            let last = String(components[1].prefix(1)).uppercased()
            return first + last
        }
        return String(username.prefix(2)).uppercased()
    }
    
    private func getCollaboratorColor(email: String) -> Color {
        let hash = abs(email.hashValue)
        let colors: [String] = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
            "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2"
        ]
        let index = hash % colors.count
        return Color(hex: colors[index])
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: -8) {
        CollaboratorAvatar(email: "john.doe@example.com", size: 32)
        CollaboratorAvatar(email: "jane.smith@example.com", size: 32)
        CollaboratorAvatar(email: "bob.wilson@example.com", size: 32)
    }
    .padding()
}
