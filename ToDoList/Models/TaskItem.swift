// Models/TaskItem.swift

import Foundation
import SwiftUI

struct TaskItem: Codable, Identifiable, Hashable {
    // MARK: - Properties
    
    let id: String
    var userId: String
    var title: String
    var description: String?
    var category: TaskCategory
    var color: String // Hex color for card background
    var priority: TaskPriority
    var isCompleted: Bool
    var dueDate: TimeInterval?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var collaborators: [String] // Array of email addresses
    var notifyOnChanges: Bool // Notification setting
    
    // MARK: - Computed Properties
    
    var backgroundColor: Color {
        Color(hex: color)
    }
    
    // MARK: - Init
    
    nonisolated init(
        id: String = UUID().uuidString,
        userId: String,
        title: String,
        description: String? = nil,
        category: TaskCategory = .personal,
        color: String = "#DDD6FE",
        priority: TaskPriority = .medium,
        isCompleted: Bool = false,
        dueDate: TimeInterval? = nil,
        createdAt: TimeInterval = Date().timeIntervalSince1970,
        updatedAt: TimeInterval = Date().timeIntervalSince1970,
        collaborators: [String] = [],
        notifyOnChanges: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.category = category
        self.color = color
        self.priority = priority
        self.isCompleted = isCompleted
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.collaborators = collaborators
        self.notifyOnChanges = notifyOnChanges
    }
    
    // MARK: - Methods
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "userId": userId,
            "title": title,
            "category": category.rawValue,
            "color": color,
            "priority": priority.rawValue,
            "isCompleted": isCompleted,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "collaborators": collaborators,
            "notifyOnChanges": notifyOnChanges
        ]
        
        if let description = description {
            dict["description"] = description
        }
        
        if let dueDate = dueDate {
            dict["dueDate"] = dueDate
        }
        
        return dict
    }
}

// MARK: - Task Category

enum TaskCategory: String, Codable, CaseIterable, Hashable {
    case lifestyle = "Lifestyle"
    case work = "Work"
    case personal = "Personal"
    case research = "Research"
    case design = "Design"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .lifestyle:
            return "figure.walk"
        case .work:
            return "briefcase.fill"
        case .personal:
            return "person.fill"
        case .research:
            return "book.fill"
        case .design:
            return "paintbrush.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .lifestyle:
            return Color(hex: "#FED7D7") // Pink
        case .work:
            return Color(hex: "#DBEAFE") // Blue
        case .personal:
            return Color(hex: "#DDD6FE") // Purple
        case .research:
            return Color(hex: "#D1FAE5") // Green
        case .design:
            return Color(hex: "#FEF3C7") // Yellow
        }
    }
}

// MARK: - Task Priority

enum TaskPriority: String, Codable, CaseIterable, Hashable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var displayName: String {
        return self.rawValue
    }
    
    var color: Color {
        switch self {
        case .low:
            return Color(hex: "#10B981") // Green
        case .medium:
            return Color(hex: "#F59E0B") // Orange
        case .high:
            return Color(hex: "#EF4444") // Red
        }
    }
    
    var icon: String {
        switch self {
        case .low:
            return "arrow.down.circle.fill"
        case .medium:
            return "minus.circle.fill"
        case .high:
            return "arrow.up.circle.fill"
        }
    }
}
