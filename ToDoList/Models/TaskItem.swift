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
    var isCompleted: Bool
    var subtasks: [Subtask]
    var dueDate: TimeInterval?
    var createdAt: TimeInterval
    var updatedAt: TimeInterval
    var collaborators: [String] // Array of email addresses
    var notifyOnChanges: Bool // Notification setting
    
    // MARK: - Computed Properties
    
    var completedSubtasksCount: Int {
        subtasks.filter { $0.isCompleted }.count
    }
    
    var totalSubtasksCount: Int {
        subtasks.count
    }
    
    var progress: Double {
        guard totalSubtasksCount > 0 else { return 0 }
        return Double(completedSubtasksCount) / Double(totalSubtasksCount)
    }
    
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
        isCompleted: Bool = false,
        subtasks: [Subtask] = [],
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
        self.isCompleted = isCompleted
        self.subtasks = subtasks
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
            "isCompleted": isCompleted,
            "subtasks": subtasks.map { $0.toDictionary() },
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

// MARK: - Subtask

struct Subtask: Codable, Identifiable, Hashable {
    let id: String
    var title: String
    var isCompleted: Bool
    
    nonisolated init(id: String = UUID().uuidString, title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "isCompleted": isCompleted
        ]
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
