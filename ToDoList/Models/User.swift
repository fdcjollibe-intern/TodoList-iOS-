// Models/User.swift

import Foundation

struct User: Codable, Identifiable, Equatable {
    // MARK: - Properties
    
    let id: String
    var email: String
    var displayName: String
    var createdAt: TimeInterval
    var lastLoginAt: TimeInterval?
    
    // MARK: - Computed Properties
    
    var initials: String {
        let components = displayName.split(separator: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
    
    // MARK: - Init
    
    init(id: String, email: String, displayName: String, createdAt: TimeInterval, lastLoginAt: TimeInterval? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
    
    // MARK: - Methods
    
    /// Convert to dictionary for Firebase Realtime Database
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "email": email,
            "displayName": displayName,
            "createdAt": createdAt
        ]
        
        if let lastLoginAt = lastLoginAt {
            dict["lastLoginAt"] = lastLoginAt
        }
        
        return dict
    }
    
    // MARK: - Mock Data
    
    static let mock = User(
        id: "mock-user-1",
        email: "john.doe@example.com",
        displayName: "John Doe",
        createdAt: Date().timeIntervalSince1970,
        lastLoginAt: Date().timeIntervalSince1970
    )
    
    static let mockList = [
        User(
            id: "mock-user-1",
            email: "john.doe@example.com",
            displayName: "John Doe",
            createdAt: Date().timeIntervalSince1970
        ),
        User(
            id: "mock-user-2",
            email: "jane.smith@example.com",
            displayName: "Jane Smith",
            createdAt: Date().timeIntervalSince1970
        )
    ]
}
