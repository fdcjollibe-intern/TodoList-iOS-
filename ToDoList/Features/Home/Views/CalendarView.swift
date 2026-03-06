//
//  CalendarView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct CalendarView: View {
    // MARK: - Properties
    
    @State private var selectedDate = Date()
    @State private var selectedTask: TaskItem?
    
    // Mock data for preview - in production, fetch from database
    private let mockTasks: [TaskItem] = [
        TaskItem(
            userId: "test",
            title: "Favorite UX Book",
            description: "Lean UX: Applying Lean Principles to Improve User Experience.",
            category: .design,
            color: "#DDD6FE",
            subtasks: [],
            dueDate: Date().timeIntervalSince1970
        ),
        TaskItem(
            userId: "test",
            title: "Webflow Web Design",
            description: nil,
            category: .design,
            color: "#FEF3C7",
            subtasks: [
                Subtask(title: "Follow the modern Styles", isCompleted: false),
                Subtask(title: "10x Rules", isCompleted: false)
            ],
            dueDate: Date().timeIntervalSince1970 + 86400 * 7
        ),
        TaskItem(
            userId: "test",
            title: "Smart Home UX/UI Project",
            description: nil,
            category: .design,
            color: "#DBEAFE",
            subtasks: [
                Subtask(title: "Interview with Stake Holders", isCompleted: false),
                Subtask(title: "UX Research", isCompleted: false)
            ],
            dueDate: Date().timeIntervalSince1970 + 86400 * 3
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Calendar
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .tint(Color.appPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(Color.appSurface)
            .cornerRadius(16)
            .padding(.horizontal, Spacing.xl)
            
            // Tasks for selected date
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    Text("Tasks for \(formattedDate)")
                        .font(Typography.title3)
                        .foregroundStyle(Color.textPrimary)
                    
                    Spacer()
                    
                    Text("\(filteredTasks.count)")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.lg)
                
                // Task List
                if filteredTasks.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.exclamationmark",
                        title: "No tasks scheduled",
                        subtitle: "No tasks are scheduled for this date"
                    )
                    .padding(.top, Spacing.xxl)
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.md) {
                            ForEach(filteredTasks) { task in
                                TaskListRow(task: task) {
                                    selectedTask = task
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.xl)
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
            
            Spacer()
        }
        .background(Color.appBackground)
        .navigationDestination(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Calendar")
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Schedule & Tasks")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.lg)
    }
    
    // MARK: - Computed Properties
    
    private var filteredTasks: [TaskItem] {
        let calendar = Calendar.current
        return mockTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDate = Date(timeIntervalSince1970: dueDate)
            return calendar.isDate(taskDate, inSameDayAs: selectedDate)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Task List Row

struct TaskListRow: View {
    let task: TaskItem
    let action: () -> Void
    
    init(task: TaskItem, action: @escaping () -> Void) {
        self.task = task
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Color indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: task.color))
                    .frame(width: 4, height: 60)
                
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    // Title
                    Text(task.title)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(2)
                    
                    // Category and Time
                    HStack(spacing: Spacing.sm) {
                        Text(task.category.displayName)
                            .font(Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 2)
                            .background(Color(hex: task.color).opacity(0.2))
                            .cornerRadius(6)
                        
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.system(size: 10))
                                Text(formatTime(dueDate))
                                    .font(Typography.caption)
                            }
                            .foregroundStyle(Color.textTertiary)
                        }
                    }
                    
                    // Progress if has subtasks
                    if !task.subtasks.isEmpty {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.appSuccess)
                            
                            Text("\(task.completedSubtasksCount)/\(task.totalSubtasksCount) completed")
                                .font(Typography.caption)
                                .foregroundStyle(Color.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Completion status
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(task.isCompleted ? Color.appSuccess : Color.textTertiary)
            }
            .padding(Spacing.md)
            .background(Color.appSurface)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func formatTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CalendarView()
    }
}
