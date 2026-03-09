//
//  CalendarViewModel.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/9/26.
//

import Foundation
import Observation

@Observable
final class CalendarViewModel {
    private let databaseService: RealtimeDatabaseService
    private let userId: String
    
    var tasks: [TaskItem] = []
    var currentUser: User?
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
            // Get current user to fetch their email
            if currentUser == nil {
                currentUser = try await databaseService.fetchUser(userId: userId)
            }
            
            guard let userEmail = currentUser?.email else {
                tasks = try await databaseService.fetchTasks(userId: userId)
                isLoading = false
                return
            }
            
            // Fetch both owned and collaborated tasks
            tasks = try await databaseService.fetchAllUserTasks(userId: userId, userEmail: userEmail)
        } catch {
            errorMessage = "Failed to load tasks: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
