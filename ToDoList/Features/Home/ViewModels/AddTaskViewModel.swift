//
//  AddTaskViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/9/26.
//

import Foundation
import Observation

@Observable
final class AddTaskViewModel {
    private let databaseService = RealtimeDatabaseService.shared
    private let userId: String
    
    var title = ""
    var description = ""
    var selectedCategory: TaskCategory = .personal
    var selectedPriority: TaskPriority = .medium
    var selectedColor = ColorPalette.taskColors[0]
    var hasDueDate = false
    var dueDate = Date()
    var collaborators: [String] = []
    var collaboratorEmail = ""
    var isLoading = false
    var errorMessage: String?
    var showPremiumBanner = false
    
    init(userId: String) {
        self.userId = userId
    }
    
    var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func addCollaborator() {
        let email = collaboratorEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !email.isEmpty else { return }
        
        // Check if already at limit
        if collaborators.count >= 3 {
            showPremiumBanner = true
            return
        }
        
        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            return
        }
        
        // Check if not already added
        guard !collaborators.contains(email) else {
            collaboratorEmail = ""
            return
        }
        
        collaborators.append(email)
        collaboratorEmail = ""
    }
    
    func removeCollaborator(email: String) {
        collaborators.removeAll { $0 == email }
    }
    
    @MainActor
    func createTask() async -> Bool {
        guard canCreate else { return false }
        
        isLoading = true
        errorMessage = nil
        
        let task = TaskItem(
            userId: userId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            category: selectedCategory,
            color: selectedColor,
            priority: selectedPriority,
            dueDate: dueDate.timeIntervalSince1970,
            collaborators: collaborators,
            notifyOnChanges: true
        )
        
        do {
            try await databaseService.saveTask(task)
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to create task: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
}
