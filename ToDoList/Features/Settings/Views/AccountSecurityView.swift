//
//  AccountSecurityView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct AccountSecurityView: View {
    // MARK: - Properties
    
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Security Options Card
                VStack(spacing: 0) {
                    // Change Password
                    NavigationLink {
                        ChangePasswordView(viewModel: viewModel)
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.appPrimary)
                                .frame(width: 32)
                            
                            Text("Change Password")
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Color.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textTertiary)
                        }
                        .padding(Spacing.lg)
                    }
                    
                    Divider()
                        .padding(.leading, 56)
                    
                    // Delete Account
                    Button {
                        viewModel.showDeleteAccountModal = true
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "trash")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.appDestructive)
                                .frame(width: 32)
                            
                            Text("Delete Account")
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Color.appDestructive)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.textTertiary)
                        }
                        .padding(Spacing.lg)
                    }
                }
                .background(Color.appSurface)
                .cornerRadius(16)
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.xl)
                
                Spacer()
            }
        }
        .navigationTitle("Account & Security")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $viewModel.showDeleteAccountModal) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Coming Soon")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AccountSecurityView(viewModel: SettingsViewModel())
    }
}
