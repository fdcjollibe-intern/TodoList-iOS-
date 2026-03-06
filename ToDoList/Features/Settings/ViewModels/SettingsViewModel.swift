//
//  SettingsViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
class SettingsViewModel {
    // MARK: - Properties
    
    var user: User?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    // Personal Info
    var firstName = ""
    var lastName = ""
    var profileColor = ""
    var profileImageUrl: String?
    
    // Change Password
    var currentPassword = ""
    var newPassword = ""
    var confirmNewPassword = ""
    
    var currentPasswordError: String?
    var newPasswordError: String?
    var confirmNewPasswordError: String?
    
    // UI States
    var showImagePicker = false
    var showImageCropper = false
    var showColorPicker = false
    var showDeleteAccountModal = false
    var selectedImage: UIImage?
    var croppedImage: UIImage?
    
    // MARK: - Computed Properties
    
    var displayName: String {
        // Use edited values if available
        if !firstName.isEmpty && !lastName.isEmpty {
            return "\(firstName) \(lastName)"
        }
        // Otherwise fallback to user object
        if let first = user?.firstName, let last = user?.lastName {
            return "\(first) \(last)"
        }
        return user?.displayName ?? ""
    }
    
    var isChangePasswordValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        !confirmNewPassword.isEmpty &&
        newPassword == confirmNewPassword &&
        newPassword.isValidPassword
    }
    
    // MARK: - Init
    
    init() {
        Task {
            await loadCurrentUser()
        }
    }
    
    // MARK: - Methods
    
    /// Load current user data
    func loadCurrentUser() async {
        guard let userId = await FirebaseAuthService.shared.currentUserId else {
            errorMessage = "No user logged in"
            return
        }
        
        do {
            let fetchedUser = try await RealtimeDatabaseService.shared.fetchUser(userId: userId)
            user = fetchedUser
            
            // Populate first and last name from user object
            if let userFirstName = fetchedUser.firstName, let userLastName = fetchedUser.lastName {
                firstName = userFirstName
                lastName = userLastName
            } else {
                // If not set, try to split displayName
                let nameParts = fetchedUser.displayName.split(separator: " ")
                if nameParts.count >= 2 {
                    firstName = String(nameParts.first ?? "")
                    lastName = String(nameParts.dropFirst().joined(separator: " "))
                } else {
                    firstName = fetchedUser.displayName
                    lastName = ""
                }
            }
            
            profileColor = fetchedUser.profilePhoto ?? User.randomPastelColor()
            
            // Check if profile photo is a URL or a color
            if let photo = fetchedUser.profilePhoto, photo.hasPrefix("http") {
                profileImageUrl = photo
            }
        } catch {
            errorMessage = "Failed to load user data: \(error.localizedDescription)"
        }
    }
    
    /// Clear error and success messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    /// Update personal info
    func updatePersonalInfo() async {
        guard var currentUser = user else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Validate inputs
        guard !firstName.trimmed.isEmpty else {
            errorMessage = "First name is required"
            isLoading = false
            return
        }
        
        guard !lastName.trimmed.isEmpty else {
            errorMessage = "Last name is required"
            isLoading = false
            return
        }
        
        do {
            // Update user object
            currentUser.firstName = firstName.trimmed
            currentUser.lastName = lastName.trimmed
            currentUser.displayName = "\(firstName.trimmed) \(lastName.trimmed)"
            currentUser.profilePhoto = profileImageUrl ?? profileColor
            
            // Save to database
            try await RealtimeDatabaseService.shared.updateUser(currentUser)
            
            user = currentUser
            successMessage = "Profile updated successfully"
            isLoading = false
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Upload profile photo to Cloudinary
    func uploadProfilePhoto() async {
        guard let image = croppedImage else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("Starting image upload to Cloudinary...")
            //let imageUrl = try await CloudinaryService.shared.uploadImage(image)
            let imageUrl = try await CloudinaryService.shared.uploadImageSigned(image)
            print("Image uploaded successfully: \(imageUrl)")
            
            profileImageUrl = imageUrl
            
            // Update user profile
            await updatePersonalInfo()
            
            // Clear temporary images
            selectedImage = nil
            croppedImage = nil
            
            isLoading = false
        } catch let error as CloudinaryError {
            print("Cloudinary error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            isLoading = false
        } catch {
            print("Upload error: \(error)")
            errorMessage = "Failed to upload image: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Remove profile photo (set to color)
    func removeProfilePhoto() {
        profileImageUrl = nil
        if profileColor.isEmpty {
            profileColor = User.randomPastelColor()
        }
        
        Task {
            await updatePersonalInfo()
        }
    }
    
    /// Change password
    func changePassword() async {
        isLoading = true
        errorMessage = nil
        currentPasswordError = nil
        newPasswordError = nil
        confirmNewPasswordError = nil
        
        // Validate current password
        guard !currentPassword.isEmpty else {
            currentPasswordError = "Current password is required"
            isLoading = false
            return
        }
        
        // Validate new password
        guard !newPassword.isEmpty else {
            newPasswordError = "New password is required"
            isLoading = false
            return
        }
        
        guard newPassword.isValidPassword else {
            newPasswordError = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        // Validate confirm password
        guard newPassword == confirmNewPassword else {
            confirmNewPasswordError = "Passwords do not match"
            isLoading = false
            return
        }
        
        do {
            // Re-authenticate with current password first
            guard let email = await FirebaseAuthService.shared.currentUserEmail else {
                throw AuthError.noUserLoggedIn
            }
            
            _ = try await FirebaseAuthService.shared.signIn(email: email, password: currentPassword)
            
            // Update password
            try await FirebaseAuthService.shared.updatePassword(newPassword: newPassword)
            
            successMessage = "Password changed successfully"
            currentPassword = ""
            newPassword = ""
            confirmNewPassword = ""
            isLoading = false
        } catch {
            errorMessage = "Failed to change password: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Logout
    func logout() async {
        isLoading = true
        
        do {
            try await FirebaseAuthService.shared.signOut()
            
            // Clear UserDefaults
            UserDefaults.standard.removeObject(forKey: "userId")
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.synchronize()
            
            isLoading = false
        } catch {
            errorMessage = "Failed to logout: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    /// Handle image selection
    func onImageSelected() {
        if selectedImage != nil {
            showImageCropper = true
        }
    }
    
    /// Handle image cropped
    func onImageCropped() {
        if croppedImage != nil {
            Task {
                await uploadProfilePhoto()
            }
        }
    }
    
    /// Handle color selected
    func onColorSelected() {
        profileImageUrl = nil
        Task {
            await updatePersonalInfo()
        }
    }
}
