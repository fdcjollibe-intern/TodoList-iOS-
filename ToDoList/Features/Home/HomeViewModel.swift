//
//  HomeViewModel.swift
//  ToDoList
//
//  Created on 2024.
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    private let databaseService: RealtimeDatabaseService
    private let userId: String
    
    var tasks: [TaskItem] = []
    var isLoading = false
    var errorMessage: String?
    
    init(databaseService: RealtimeDatabaseService = .shared, userId: String) {
        self.databaseService = databaseService
        self.userId = userId
    }
    
    @MainActor
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tasks = try await databaseService.fetchTasks(userId: userId)
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func deleteTask(_ task: TaskItem) async {
        do {
            try await databaseService.deleteTask(userId: userId, taskId: task.id)
            tasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    func toggleTaskCompletion(_ task: TaskItem) async {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.updatedAt = Date().timeIntervalSince1970
        
        do {
            try await databaseService.updateTask(updatedTask)
            tasks[index] = updatedTask
        } catch {
            errorMessage = "Failed to update task: \(error.localizedDescription)"
        }
    }
}
