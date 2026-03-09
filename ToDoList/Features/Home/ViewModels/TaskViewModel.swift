//
//  TaskViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

@Observable
class TaskViewModel {
    // MARK: - Properties
    
    var task: TaskItem
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?
    
    private let databaseService = RealtimeDatabaseService.shared
    
    // MARK: - Init
    
    init(task: TaskItem) {
        self.task = task
    }
    
    // MARK: - Task Operations
    
    /// Update task in database
    @MainActor
    func updateTask() async {
        isLoading = true
        errorMessage = nil
        
        do {
            var updatedTask = task
            updatedTask.updatedAt = Date().timeIntervalSince1970
            
            try await databaseService.updateTask(updatedTask)
            self.task = updatedTask
            successMessage = "Task updated successfully"
            
            // Clear success message after 2 seconds
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                successMessage = nil
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Delete task
    @MainActor
    func deleteTask() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await databaseService.deleteTask(userId: task.userId, taskId: task.id)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Task Mutations
    
    func updateTitle(_ title: String) {
        task.title = title
    }
    
    func updateDescription(_ description: String?) {
        task.description = description
    }
    
    func updateColor(_ color: String) {
        task.color = color
    }
    
    func updateCategory(_ category: TaskCategory) {
        task.category = category
    }
    
    func updatePriority(_ priority: TaskPriority) {
        task.priority = priority
    }
    
    func updateDueDate(_ date: Date?) {
        task.dueDate = date?.timeIntervalSince1970
    }
    
    @MainActor
    func toggleCompletion() async {
        task.isCompleted.toggle()
        // Auto-save when toggling completion
        await updateTask()
    }
    
    // MARK: - Collaborator Operations
    
    func addCollaborator(email: String) {
        guard !task.collaborators.contains(email) else { return }
        task.collaborators.append(email)
    }
    
    func removeCollaborator(email: String) {
        task.collaborators.removeAll { $0 == email }
    }
    
    // MARK: - Validation
    
    var canSave: Bool {
        !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
