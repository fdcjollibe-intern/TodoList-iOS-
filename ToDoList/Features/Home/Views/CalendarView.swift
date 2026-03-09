//
//  CalendarView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI
import FirebaseAuth

struct CalendarView: View {
    // MARK: - Properties
    
    @State private var selectedDate = Date()
    @State private var selectedTask: TaskItem?
    @State private var viewModel: CalendarViewModel?
    @State private var showMonthPicker = false
    
    private var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with date selector
            headerSection
            
            // Horizontal Date Picker
            dateScrollSection
            
            // Task count
            taskCountSection
            
            // Timeline
            timelineSection
        }
        .background(Color.appBackground)
        .navigationDestination(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .onChange(of: selectedTask) { oldValue, newValue in
            if oldValue != nil && newValue == nil {
                Task {
                    await viewModel?.loadTasks()
                }
            }
        }
        .task {
            if viewModel == nil, let userId = currentUser?.uid {
                viewModel = CalendarViewModel(userId: userId)
                await viewModel?.loadTasks()
            }
        }
        .refreshable {
            await viewModel?.loadTasks()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            Button(action: {
                // Back action if needed
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textPrimary)
            }
            
            Spacer()
            
            Text("Schedule")
                .font(Typography.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            Button(action: {
                // Menu action
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
    
    private var dateScrollSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Month/Year selector
            Button(action: {
                showMonthPicker.toggle()
            }) {
                HStack {
                    Text(formattedMonthYear)
                        .font(Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            // Horizontal date scroll
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(dateRange, id: \.self) { date in
                            DateButton(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                action: {
                                    withAnimation {
                                        selectedDate = date
                                    }
                                }
                            )
                            .id(date)
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .onAppear {
                    proxy.scrollTo(selectedDate, anchor: .center)
                }
            }
        }
        .padding(.vertical, Spacing.md)
    }
    
    private var taskCountSection: some View {
        HStack {
            Text("you have total \(filteredTasks.count) tasks today")
                .font(Typography.caption)
                .foregroundStyle(Color.textSecondary)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Timeline")
                .font(Typography.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, Spacing.lg)
            
            if filteredTasks.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    title: "No tasks scheduled",
                    subtitle: "No tasks are scheduled for this date"
                )
                .padding(.top, Spacing.xxl)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(timeSlots, id: \.self) { timeSlot in
                            TimelineRow(
                                timeSlot: timeSlot,
                                tasks: tasksForTimeSlot(timeSlot),
                                onTaskTap: { task in
                                    selectedTask = task
                                }
                            )
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredTasks: [TaskItem] {
        let calendar = Calendar.current
        let tasks = viewModel?.tasks ?? []
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDate = Date(timeIntervalSince1970: dueDate)
            return calendar.isDate(taskDate, inSameDayAs: selectedDate)
        }.sorted { $0.dueDate ?? 0 < $1.dueDate ?? 0 }
    }
    
    private var dateRange: [Date] {
        let calendar = Calendar.current
        let today = selectedDate
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    private var timeSlots: [Date] {
        let calendar = Calendar.current
        var slots: [Date] = []
        
        for hour in 9...23 {
            if let timeSlot = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: selectedDate) {
                slots.append(timeSlot)
            }
        }
        
        return slots
    }
    
    private func tasksForTimeSlot(_ timeSlot: Date) -> [TaskItem] {
        let calendar = Calendar.current
        return filteredTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let taskDate = Date(timeIntervalSince1970: dueDate)
            let taskHour = calendar.component(.hour, from: taskDate)
            let slotHour = calendar.component(.hour, from: timeSlot)
            return taskHour == slotHour
        }
    }
    
    private var formattedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

// MARK: - Date Button

private struct DateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dayNumber)
                    .font(.system(size: 16, weight: .semibold))
                Text(dayName)
                    .font(.system(size: 12))
            }
            .foregroundStyle(isSelected ? .white : Color.textPrimary)
            .frame(width: 50, height: 70)
            .background(isSelected ? Color.appPrimary : Color.white)
            .cornerRadius(12)
        }
    }
    
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
}

// MARK: - Timeline Row

private struct TimelineRow: View {
    let timeSlot: Date
    let tasks: [TaskItem]
    let onTaskTap: (TaskItem) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            // Time label
            Text(formattedTime)
                .font(.system(size: 14))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 70, alignment: .leading)
            
            // Tasks or empty space
            if tasks.isEmpty {
                Spacer()
                    .frame(height: 44)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(tasks) { task in
                        TimelineTaskCard(task: task) {
                            onTaskTap(task)
                        }
                    }
                }
            }
        }
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: timeSlot)
    }
}

// MARK: - Timeline Task Card

private struct TimelineTaskCard: View {
    let task: TaskItem
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                // Collaborator avatars
                if !task.collaborators.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(task.collaborators.prefix(2), id: \.self) { email in
                            CollaboratorAvatar(email: email, size: 32)
                        }
                        
                        if task.collaborators.count > 2 {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("+\(task.collaborators.count - 2)")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(Color.textPrimary)
                                )
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    if !task.isCompleted {
                        Text("0%")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color(hex: task.color))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CalendarView()
    }
}
