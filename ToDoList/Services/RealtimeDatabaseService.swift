// Services/RealtimeDatabaseService.swift

import Foundation
import FirebaseDatabase

/// Actor handling all Firebase Realtime Database operations
actor RealtimeDatabaseService {
    // MARK: - Singleton
    
    static let shared = RealtimeDatabaseService()
    
    private init() {}
    
    // MARK: - Properties
    
    private let database = Database.database().reference()
    
    // MARK: - User Operations
    
    /// Save user data to database
    func saveUser(_ user: User) async throws {
        let userRef = database.child(DBPath.users).child(user.id)
        try await userRef.setValue(user.toDictionary())
    }
    
    /// Fetch user data from database
    func fetchUser(userId: String) async throws -> User {
        let userRef = database.child(DBPath.users).child(userId)
        let snapshot = try await userRef.getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            throw DatabaseError.dataNotFound
        }
        
        return try parseUser(from: value)
    }
    
    /// Update user data
    func updateUser(_ user: User) async throws {
        let userRef = database.child(DBPath.users).child(user.id)
        try await userRef.updateChildValues(user.toDictionary())
    }
    
    /// Delete user data
    func deleteUser(userId: String) async throws {
        let userRef = database.child(DBPath.users).child(userId)
        try await userRef.removeValue()
    }
    
    // MARK: - Generic Operations
    
    /// Set value at path
    func setValue(_ value: Any, at path: String) async throws {
        try await database.child(path).setValue(value)
    }
    
    /// Get value at path
    func getValue(at path: String) async throws -> Any? {
        let snapshot = try await database.child(path).getData()
        return snapshot.value
    }
    
    /// Update values at path
    func updateValues(_ values: [String: Any], at path: String) async throws {
        try await database.child(path).updateChildValues(values)
    }
    
    /// Delete value at path
    func deleteValue(at path: String) async throws {
        try await database.child(path).removeValue()
    }
    
    // MARK: - Observers
    
    /// Observe value changes at path
    func observeValue(at path: String, completion: @escaping (DataSnapshot) -> Void) -> DatabaseHandle {
        return database.child(path).observe(.value) { snapshot in
            completion(snapshot)
        }
    }
    
    /// Remove observer
    func removeObserver(at path: String, handle: DatabaseHandle) {
        database.child(path).removeObserver(withHandle: handle)
    }
    
    /// Remove all observers at path
    func removeAllObservers(at path: String) {
        database.child(path).removeAllObservers()
    }
    
    // MARK: - Helper Methods
    
    private func parseUser(from data: [String: Any]) throws -> User {
        guard let id = data["id"] as? String,
              let email = data["email"] as? String,
              let displayName = data["displayName"] as? String,
              let createdAt = data["createdAt"] as? TimeInterval else {
            throw DatabaseError.invalidData
        }
        
        let lastLoginAt = data["lastLoginAt"] as? TimeInterval
        
        return User(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt
        )
    }
}

// MARK: - Database Errors

enum DatabaseError: LocalizedError {
    case dataNotFound
    case invalidData
    case permissionDenied
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "Data not found"
        case .invalidData:
            return "Invalid data format"
        case .permissionDenied:
            return "Permission denied"
        case .networkError:
            return ErrorMessage.networkError
        case .unknown:
            return ErrorMessage.genericError
        }
    }
}
