//
//  ScheduleTimelineView.swift
//  ToDoList
//
//  Created on 2024.
//

import SwiftUI
import FirebaseAuth

struct ScheduleTimelineView: View {
    // MARK: - Properties
    
    @State private var selectedDate = Date()
    @State private var selectedTask: TaskItem?
    @State private var viewModel: HomeViewModel?
    
    private var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    // Calendar days for selector
    private let calendar = Calendar.current
    private var weekDays: [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Date Selector
            dateSelector
            
            // Timeline Label
            HStack {
                Text("Timeline")
                    .font(Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            
            // Timeline with Tasks
            timelineView
        }
        .background(Color.appBackground)
        .navigationDestination(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .task {
            // Initialize viewModel with current user ID
            if viewModel == nil, let userId = currentUser?.uid {
                viewModel = HomeViewModel(userId: userId)
                await viewModel?.loadTasks()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Schedule")
                    .font(Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Text("You have \(tasksForSelectedDate.count) tasks today")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Color.appSurface)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    private var dateSelector: some View {
        VStack(spacing: Spacing.sm) {
            // Month and Year
            HStack {
                Text(monthYearString)
                    .font(Typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            // Week Day Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(weekDays, id: \.self) { date in
                        DayButton(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
        .padding(.vertical, Spacing.md)
        .background(Color.appSurface)
        .cornerRadius(16)
        .padding(.horizontal, Spacing.lg)
    }
    
    private var timelineView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(timeSlots, id: \.self) { hour in
                    TimelineRow(
                        hour: hour,
                        tasks: tasksForHour(hour)
                    ) { task in
                        selectedTask = task
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, 100) // Space for tab bar
        }
    }
    
    // MARK: - Computed Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var tasksForSelectedDate: [TaskItem] {
        guard let tasks = viewModel?.tasks else { return [] }
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDate = Date(timeIntervalSince1970: dueDate)
            return calendar.isDate(taskDate, inSameDayAs: selectedDate)
        }
    }
    
    private var timeSlots: [Int] {
        Array(0...23)
    }
    
    private func tasksForHour(_ hour: Int) -> [TaskItem] {
        tasksForSelectedDate.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDate = Date(timeIntervalSince1970: dueDate)
            let taskHour = calendar.component(.hour, from: taskDate)
            return taskHour == hour
        }
    }
}

// MARK: - Day Button

private struct DayButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : Color.textPrimary)
                
                Text(dayName)
                    .font(.system(size: 12))
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : Color.textSecondary)
            }
            .frame(width: 50)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.appPrimary : Color.clear)
            .cornerRadius(12)
        }
    }
}

// MARK: - Timeline Row

private struct TimelineRow: View {
    let hour: Int
    let tasks: [TaskItem]
    let onTaskTap: (TaskItem) -> Void
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Time Label
            Text(timeString)
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 70, alignment: .leading)
            
            // Task Pills
            VStack(alignment: .leading, spacing: Spacing.xs) {
                if tasks.isEmpty {
                    // Empty timeline line
                    Divider()
                        .frame(height: 40)
                } else {
                    ForEach(tasks) { task in
                        TimelineTaskPill(task: task) {
                            onTaskTap(task)
                        }
                    }
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
}

// MARK: - Timeline Task Pill

private struct TimelineTaskPill: View {
    let task: TaskItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.sm) {
                // Avatar bubbles
                HStack(spacing: -8) {
                    Circle()
                        .fill(Color(hex: task.color).opacity(0.8))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: task.category.icon)
                                .font(.system(size: 14))
                                .foregroundStyle(.white)
                        )
                    
                    if !task.collaborators.isEmpty {
                        ForEach(task.collaborators.prefix(2), id: \.self) { email in
                            Circle()
                                .fill(Color(hex: task.color).opacity(0.6))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(String(email.prefix(1)).uppercased())
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                }
                
                // Task Title
                Text(task.title)
                    .font(Typography.bodyRegular)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                Capsule()
                    .fill(Color(hex: task.color))
            )
            .shadow(color: Color(hex: task.color).opacity(0.3), radius: 8, y: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    ScheduleTimelineView()
}
