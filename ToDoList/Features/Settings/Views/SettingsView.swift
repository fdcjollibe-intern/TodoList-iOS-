//
//  SettingsView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Properties
    
    @State private var viewModel = SettingsViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Spacing.xxl) {
                        // Profile Card
                        profileCard
                            .padding(.top, Spacing.xl)
                        
                        // Settings Categories
                        VStack(spacing: Spacing.md) {
                            // Personal Info
                            NavigationLink {
                                PersonalInfoView(viewModel: viewModel)
                            } label: {
                                SettingsCategoryRow(
                                    icon: "person.circle",
                                    title: "Personal Info",
                                    iconColor: Color.appPrimary
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // Account & Security
                            NavigationLink {
                                AccountSecurityView(viewModel: viewModel)
                            } label: {
                                SettingsCategoryRow(
                                    icon: "lock.shield",
                                    title: "Account & Security",
                                    iconColor: Color.appSecondary
                                )
                            }
                            
                            Divider()
                                .padding(.leading, 56)
                            
                            // Terms & Conditions
                            Button {
                                // Navigate to terms
                            } label: {
                                SettingsCategoryRow(
                                    icon: "doc.text",
                                    title: "Terms & Conditions",
                                    iconColor: Color.appTertiary
                                )
                            }
                        }
                        .background(Color.appSurface)
                        .cornerRadius(16)
                        .padding(.horizontal, Spacing.xl)
                        
                        // Logout Button
                        PrimaryButton(
                            title: "Logout",
                            isLoading: viewModel.isLoading,
                            backgroundColor: Color.appDestructive
                        ) {
                            Task {
                                await viewModel.logout()
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadCurrentUser()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var profileCard: some View {
        VStack(spacing: Spacing.md) {
            // Profile Image
            if let imageUrl = viewModel.profileImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(hex: viewModel.profileColor))
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: viewModel.profileColor))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text(viewModel.user?.initials ?? "")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            
            // Full Name
            Text(viewModel.displayName)
                .font(Typography.title2)
                .foregroundStyle(Color.textPrimary)
            
            // Email
            Text(viewModel.user?.email ?? "")
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

// MARK: - Settings Category Row

struct SettingsCategoryRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            Text(title)
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
