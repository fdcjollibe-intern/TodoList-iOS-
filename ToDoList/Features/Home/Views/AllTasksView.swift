//
//  AllTasksView.swift
//  ToDoList
//
//  Created on 2026.
//

import SwiftUI

enum TaskFilterType: String, CaseIterable {
    case all = "All"
    case lowPriority = "Low Priority"
    case mediumPriority = "Medium Priority"
    case highPriority = "High Priority"
}

enum TaskSortType: String, CaseIterable {
    case recentToOldest = "Recent to Oldest"
    case oldestToRecent = "Oldest to Recent"
}

struct AllTasksView: View {
    let title: String
    let tasks: [TaskItem]
    
    @State private var searchText = ""
    @State private var selectedFilter: TaskFilterType = .all
    @State private var selectedSort: TaskSortType = .recentToOldest
    @State private var showFilterSheet = false
    @State private var selectedTask: TaskItem?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: Spacing.md) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.textSecondary)
                    
                    TextField("Search tasks...", text: $searchText)
                        .font(Typography.bodyRegular)
                }
                .padding(Spacing.md)
                .background(Color.appBackground)
                .cornerRadius(12)
                
                Button(action: {
                    showFilterSheet = true
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                        Text("Filter")
                            .font(Typography.caption)
                    }
                    .foregroundStyle(Color.appPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.appPrimary.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            
            // Active Filters Display
            if selectedFilter != .all || selectedSort != .recentToOldest {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        if selectedFilter != .all {
                            FilterChip(text: selectedFilter.rawValue) {
                                selectedFilter = .all
                            }
                        }
                        if selectedSort != .recentToOldest {
                            FilterChip(text: selectedSort.rawValue) {
                                selectedSort = .recentToOldest
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                }
                .padding(.bottom, Spacing.sm)
            }
            
            // Task Count
            HStack {
                Text("\(filteredAndSortedTasks.count) tasks")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textSecondary)
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            
            // Tasks List
            if filteredAndSortedTasks.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No tasks found",
                    subtitle: "Try adjusting your filters"
                )
                .padding(.top, Spacing.xxl)
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(filteredAndSortedTasks) { task in
                            if title.contains("Completed") {
                                CompletedTaskRow(task: task) {
                                    selectedTask = task
                                }
                            } else {
                                ModernTaskCard(task: task) {
                                    selectedTask = task
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.bottom, Spacing.xl)
                }
            }
        }
        .background(Color.appBackground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedTask) { task in
            TaskDetailView(task: task)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(
                selectedFilter: $selectedFilter,
                selectedSort: $selectedSort
            )
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredAndSortedTasks: [TaskItem] {
        var result = tasks
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply priority filter
        switch selectedFilter {
        case .all:
            break
        case .lowPriority:
            result = result.filter { $0.priority == .low }
        case .mediumPriority:
            result = result.filter { $0.priority == .medium }
        case .highPriority:
            result = result.filter { $0.priority == .high }
        }
        
        // Apply sort
        switch selectedSort {
        case .recentToOldest:
            result.sort { $0.createdAt > $1.createdAt }
        case .oldestToRecent:
            result.sort { $0.createdAt < $1.createdAt }
        }
        
        return result
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(text)
                .font(Typography.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
            }
        }
        .foregroundStyle(Color.appPrimary)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.xs)
        .background(Color.appPrimary.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Binding var selectedFilter: TaskFilterType
    @Binding var selectedSort: TaskSortType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Priority Filter") {
                    ForEach(TaskFilterType.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                        }) {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.appPrimary)
                                }
                            }
                        }
                    }
                }
                
                Section("Sort By") {
                    ForEach(TaskSortType.allCases, id: \.self) { sort in
                        Button(action: {
                            selectedSort = sort
                        }) {
                            HStack {
                                Text(sort.rawValue)
                                    .foregroundStyle(Color.textPrimary)
                                Spacer()
                                if selectedSort == sort {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.appPrimary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllTasksView(
            title: "All Tasks",
            tasks: []
        )
    }
}
