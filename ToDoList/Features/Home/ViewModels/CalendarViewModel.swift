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
}
