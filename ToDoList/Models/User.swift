//
//  User.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//


import Foundation
import SwiftUI

struct User: Codable, Identifiable, Equatable {
    // MARK: - Properties
    
    let id: String
    var email: String
    var displayName: String
    var firstName: String?
    var lastName: String?
    var createdAt: TimeInterval
    var lastLoginAt: TimeInterval?
    var appTheme: String = "Light"
    var profilePhoto: String?
    
    // MARK: - Computed Properties
    
    var initials: String {
        let components = displayName.split(separator: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
    
    var profileColor: Color {
        if let profilePhoto = profilePhoto {
            return Color(hex: profilePhoto)
        }
        return Color(hex: User.randomPastelColor())
    }
    
    // MARK: - Init
    
    nonisolated init(
        id: String,
        email: String,
        displayName: String,
        firstName: String? = nil,
        lastName: String? = nil,
        createdAt: TimeInterval,
        lastLoginAt: TimeInterval? = nil,
        appTheme: String = "Light",
        profilePhoto: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.firstName = firstName
        self.lastName = lastName
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.appTheme = appTheme
        self.profilePhoto = profilePhoto ?? User.randomPastelColor()
    }
    
    /// Generate a random pastel color hex string for profile picture
    static func randomPastelColor() -> String {
        return PastelColors.random()
    }
    
    // MARK: - Methods
    
    /// Convert to dictionary for Firebase Realtime Database
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "email": email,
            "displayName": displayName,
            "createdAt": createdAt,
            "appTheme": appTheme
        ]
        
        if let firstName = firstName {
            dict["firstName"] = firstName
        }
        
        if let lastName = lastName {
            dict["lastName"] = lastName
        }
        
        if let lastLoginAt = lastLoginAt {
            dict["lastLoginAt"] = lastLoginAt
        }
        
        if let profilePhoto = profilePhoto {
            dict["profilePhoto"] = profilePhoto
        }
        
        return dict
    }
}
