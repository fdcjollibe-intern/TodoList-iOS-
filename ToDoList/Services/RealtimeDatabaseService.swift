//
//  RealtimeDatabaseService.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//


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
    
    /// Fetch user by email
    func fetchUserByEmail(_ email: String) async throws -> User? {
        let usersRef = database.child(DBPath.users)
        let snapshot = try await usersRef.getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        
        // Search through all users to find matching email
        for (_, userData) in value {
            guard let userDict = userData as? [String: Any],
                  let userEmail = userDict["email"] as? String,
                  userEmail.lowercased() == email.lowercased() else {
                continue
            }
            return try parseUser(from: userDict)
        }
        
        return nil
    }
    
    // MARK: - Task Operations
    
    /// Save task to database
    func saveTask(_ task: TaskItem) async throws {
        let taskRef = database.child(DBPath.tasks).child(task.userId).child(task.id)
        try await taskRef.setValue(task.toDictionary())
    }
    
    /// Fetch all tasks for a user
    func fetchTasks(userId: String) async throws -> [TaskItem] {
        let tasksRef = database.child(DBPath.tasks).child(userId)
        let snapshot = try await tasksRef.getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            return []
        }
        
        return try value.compactMap { _, taskData in
            guard let taskDict = taskData as? [String: Any] else { return nil }
            return try parseTask(from: taskDict)
        }
    }
    
    /// Fetch single task
    func fetchTask(userId: String, taskId: String) async throws -> TaskItem {
        let taskRef = database.child(DBPath.tasks).child(userId).child(taskId)
        let snapshot = try await taskRef.getData()
        
        guard let value = snapshot.value as? [String: Any] else {
            throw DatabaseError.dataNotFound
        }
        
        return try parseTask(from: value)
    }
    
    /// Update task
    func updateTask(_ task: TaskItem) async throws {
        let taskRef = database.child(DBPath.tasks).child(task.userId).child(task.id)
        try await taskRef.updateChildValues(task.toDictionary())
    }
    
    /// Delete task
    func deleteTask(userId: String, taskId: String) async throws {
        let taskRef = database.child(DBPath.tasks).child(userId).child(taskId)
        try await taskRef.removeValue()
    }
    
    /// Fetch tasks with due dates (for calendar)
    func fetchTasksWithDueDates(userId: String) async throws -> [TaskItem] {
        let tasks = try await fetchTasks(userId: userId)
        return tasks.filter { $0.dueDate != nil }
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
    
    nonisolated private func parseTask(from data: [String: Any]) throws -> TaskItem {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let title = data["title"] as? String,
              let categoryString = data["category"] as? String,
              let category = TaskCategory(rawValue: categoryString),
              let color = data["color"] as? String,
              let isCompleted = data["isCompleted"] as? Bool,
              let createdAt = data["createdAt"] as? TimeInterval,
              let updatedAt = data["updatedAt"] as? TimeInterval else {
            throw DatabaseError.invalidData
        }
        
        let description = data["description"] as? String
        let dueDate = data["dueDate"] as? TimeInterval
        let collaborators = data["collaborators"] as? [String] ?? []
        let notifyOnChanges = data["notifyOnChanges"] as? Bool ?? true
        let priorityString = data["priority"] as? String ?? "Medium"
        let priority = TaskPriority(rawValue: priorityString) ?? .medium
        
        return TaskItem(
            id: id,
            userId: userId,
            title: title,
            description: description,
            category: category,
            color: color,
            priority: priority,
            isCompleted: isCompleted,
            dueDate: dueDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            collaborators: collaborators,
            notifyOnChanges: notifyOnChanges
        )
    }
    
    nonisolated private func parseUser(from data: [String: Any]) throws -> User {
        guard let id = data["id"] as? String,
              let email = data["email"] as? String,
              let displayName = data["displayName"] as? String,
              let createdAt = data["createdAt"] as? TimeInterval else {
            throw DatabaseError.invalidData
        }
        
        let lastLoginAt = data["lastLoginAt"] as? TimeInterval
        let appTheme = data["appTheme"] as? String ?? "Light"
        let profilePhoto = data["profilePhoto"] as? String
        
        return User(
            id: id,
            email: email,
            displayName: displayName,
            createdAt: createdAt,
            lastLoginAt: lastLoginAt,
            appTheme: appTheme,
            profilePhoto: profilePhoto
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
