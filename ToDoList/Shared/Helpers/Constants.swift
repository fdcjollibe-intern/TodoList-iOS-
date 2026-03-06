// Shared/Helpers/Constants.swift

import Foundation

// MARK: - Database Paths

enum DBPath {
    static let users = "users"
    static let tasks = "tasks"
}

// MARK: - User Defaults Keys

enum UserDefaultsKey {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let lastSyncTimestamp = "lastSyncTimestamp"
}

// MARK: - App Configuration

enum AppConfig {
    static let appName = "ToDoList"
    static let minimumPasswordLength = 6
    static let maxTaskTitleLength = 100
    static let maxTaskDescriptionLength = 500
}

// MARK: - Error Messages

enum ErrorMessage {
    static let invalidEmail = "Please enter a valid email address"
    static let invalidPassword = "Password must be at least 6 characters"
    static let passwordMismatch = "Passwords do not match"
    static let emptyField = "This field cannot be empty"
    static let genericError = "Something went wrong. Please try again."
    static let networkError = "Network error. Please check your connection."
}
