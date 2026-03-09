//
//  PersonalInfoView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct PersonalInfoView: View {
    // MARK: - Properties
    
    @Bindable var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Profile Photo Section
                    profilePhotoSection
                    
                    // Name Fields
                    VStack(spacing: Spacing.lg) {
                        // First Name
                        VStack(spacing: Spacing.xs) {
                            Text("First Name")
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Color.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("First Name", text: $viewModel.firstName)
                                .font(Typography.bodyRegular)
                                .padding(Spacing.md)
                                .background(Color.appInputBackground)
                                .cornerRadius(12)
                                .autocapitalization(.words)
                        }
                        
                        // Last Name
                        VStack(spacing: Spacing.xs) {
                            Text("Last Name")
                                .font(Typography.bodyMedium)
                                .foregroundStyle(Color.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("Last Name", text: $viewModel.lastName)
                                .font(Typography.bodyRegular)
                                .padding(Spacing.md)
                                .background(Color.appInputBackground)
                                .cornerRadius(12)
                                .autocapitalization(.words)
                        }
                    }
                    .padding(Spacing.lg)
                    .background(Color.appSurface)
                    .cornerRadius(16)
                    
                    // Save Button
                    PrimaryButton(
                        title: "Save Changes",
                        isLoading: viewModel.isLoading,
                        isDisabled: viewModel.firstName.isEmpty || viewModel.lastName.isEmpty
                    ) {
                        Task {
                            await viewModel.updatePersonalInfo()
                        }
                    }
                    
                    // Success/Error Messages
                    if let successMessage = viewModel.successMessage {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                            Text(successMessage)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.appSuccess)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appSuccess.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 14))
                            Text(errorMessage)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.appDestructive)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.appDestructive.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.xl)
            }
        }
        .navigationTitle("Personal Info")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePickerView(image: $viewModel.selectedImage)
        }
        .sheet(isPresented: $viewModel.showImageCropper) {
            ImageCropperView(
                image: $viewModel.selectedImage,
                croppedImage: $viewModel.croppedImage
            )
        }
        .onChange(of: viewModel.selectedImage) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                print("🖼️ selectedImage changed, calling onImageSelected()")
                viewModel.onImageSelected()
            }
        }
        .onChange(of: viewModel.croppedImage) { oldValue, newValue in
            if oldValue == nil && newValue != nil {
                print("✂️ croppedImage changed, calling onImageCropped()")
                viewModel.onImageCropped()
            }
        }
        .sheet(isPresented: $viewModel.showColorPicker) {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.showColorPicker = false
                    }
                
                PastelColorPicker(selectedColor: $viewModel.profileColor)
                    .onChange(of: viewModel.profileColor) { _, _ in
                        viewModel.onColorSelected()
                    }
            }
        }
        .overlay {
            if viewModel.isLoading {
                LoadingOverlay(message: "Uploading photo...")
            }
        }
        .onAppear {
            viewModel.clearMessages()
            Task {
                await viewModel.loadCurrentUser()
            }
        }
    }
    
    // MARK: - View Components
    
    private var profilePhotoSection: some View {
        VStack(spacing: Spacing.md) {
            Text("Profile Photo")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: Spacing.lg) {
                // Profile Photo Circle
                ZStack(alignment: .bottomTrailing) {
                    if let imageUrl = viewModel.profileImageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color(hex: viewModel.profileColor))
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(hex: viewModel.profileColor))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(viewModel.user?.initials ?? "")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.white)
                            )
                    }
                    
                    // Edit Button
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        )
                }
                
                Spacer()
                
                // Action Menu
                Menu {
                    Button {
                        viewModel.showColorPicker = true
                    } label: {
                        Label("Choose Color", systemImage: "paintpalette")
                    }
                    
                    Button {
                        viewModel.showImagePicker = true
                    } label: {
                        Label("Upload Photo", systemImage: "photo")
                    }
                    
                    if viewModel.profileImageUrl != nil {
                        Button(role: .destructive) {
                            viewModel.removeProfilePhoto()
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                        }
                    }
                } label: {
                    Text("Change")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, Spacing.lg)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PersonalInfoView(viewModel: SettingsViewModel())
    }
}
