//
//  TaskDetailView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct TaskDetailView: View {
    // MARK: - Properties
    
    @State private var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isEditingTitle = false
    @State private var editingSubtaskId: String?
    @State private var showColorPicker = false
    @State private var showDatePicker = false
    @State private var showDeleteConfirmation = false
    @State private var newSubtaskTitle = ""
    @State private var selectedTab: DetailTab = .general
    @State private var collaboratorEmail = ""
    @State private var showPremiumBanner = false
    
    enum DetailTab: String, CaseIterable {
        case general = "General"
        case tasks = "Tasks"
    }
    
    // MARK: - Init
    
    init(task: TaskItem) {
        _viewModel = State(initialValue: TaskViewModel(task: task))
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color(hex: viewModel.task.color).opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Task Header Card
                taskHeaderCard
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                
                // Tab Picker
                tabPicker
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)
                
                // Tab Content
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        if selectedTab == .general {
                            generalTabContent
                        } else {
                            tasksTabContent
                        }
                        
                        // Delete Button (shown in both tabs)
                        deleteButton
                        
                        Spacer(minLength: Spacing.xxl)
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.lg)
                }
            }
            
            // Premium Banner Overlay
            if showPremiumBanner {
                PremiumBanner(isPresented: $showPremiumBanner)
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { 
                    Task {
                        await viewModel.updateTask()
                        dismiss()
                    }
                }) {
                    Text("Save")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                }
                .disabled(!viewModel.canSave)
            }
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(selectedColor: $viewModel.task.color)
        }
        .alert("Delete Task?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteTask() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This task will be permanently deleted.")
        }
        .overlay(alignment: .top) {
            if let message = viewModel.successMessage {
                SuccessBanner(message: message)
                    .padding(.top, Spacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - View Components
    
    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(DetailTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }) {
                    Text(tab.rawValue)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(selectedTab == tab ? Color.appPrimary : Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == tab ? Color.appPrimary.opacity(0.1) : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(Color.appSurface)
        .cornerRadius(12)
    }
    
    private var generalTabContent: some View {
        VStack(spacing: Spacing.xl) {
            // Description Section
            descriptionSection
            
            // Category & Color Section
            categoryColorSection
            
            // Due Date Section
            dueDateSection
            
            // Notification Toggle
            notificationSection
            
            // Collaborators Section
            collaboratorsSection
        }
    }
    
    private var tasksTabContent: some View {
        VStack(spacing: Spacing.xl) {
            // Subtasks Section
            subtasksSection
        }
    }
    
    private var taskHeaderCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Title
            if isEditingTitle {
                TextField("Task title", text: $viewModel.task.title, axis: .vertical)
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                    .textFieldStyle(.plain)
                    .padding(Spacing.sm)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
                    .onSubmit {
                        isEditingTitle = false
                    }
            } else {
                Text(viewModel.task.title)
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        isEditingTitle = true
                    }
            }
            
            // Status Toggle
            Button(action: {
                viewModel.toggleCompletion()
            }) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20))
                    Text(viewModel.task.isCompleted ? "Completed" : "Mark as complete")
                        .font(Typography.bodyMedium)
                }
                .foregroundStyle(viewModel.task.isCompleted ? Color.appSuccess : Color.textSecondary)
            }
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Description")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            TextField("Add description...", text: Binding(
                get: { viewModel.task.description ?? "" },
                set: { viewModel.updateDescription($0.isEmpty ? nil : $0) }
            ), axis: .vertical)
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textPrimary)
                .textFieldStyle(.plain)
                .padding(Spacing.md)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var categoryColorSection: some View {
        VStack(spacing: Spacing.lg) {
            // Category Picker
            VStack(alignment: .leading, spacing: Spacing.md) {
                Text("Category")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textSecondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.displayName,
                                isSelected: viewModel.task.category == category
                            ) {
                                viewModel.updateCategory(category)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Color Picker Button
            Button(action: { showColorPicker = true }) {
                HStack {
                    Text("Card Color")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.textPrimary)
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: viewModel.task.color))
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Due Date")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                if viewModel.task.dueDate != nil {
                    Button(action: {
                        viewModel.updateDueDate(nil)
                    }) {
                        Text("Clear")
                            .font(Typography.caption)
                            .foregroundStyle(Color.appDestructive)
                    }
                }
            }
            
            DatePicker(
                "Select date",
                selection: Binding(
                    get: {
                        if let dueDate = viewModel.task.dueDate {
                            return Date(timeIntervalSince1970: dueDate)
                        }
                        return Date()
                    },
                    set: { viewModel.updateDueDate($0) }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(Color.appPrimary)
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Subtasks")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            // Existing Subtasks
            ForEach(viewModel.task.subtasks) { subtask in
                subtaskRow(subtask)
            }
            
            // Add Subtask Field
            HStack(spacing: Spacing.sm) {
                TextField("Add subtask...", text: $newSubtaskTitle)
                    .font(Typography.bodyRegular)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if !newSubtaskTitle.isEmpty {
                            viewModel.addSubtask(title: newSubtaskTitle)
                            newSubtaskTitle = ""
                        }
                    }
                
                if !newSubtaskTitle.isEmpty {
                    Button(action: {
                        viewModel.addSubtask(title: newSubtaskTitle)
                        newSubtaskTitle = ""
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(12)
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private func subtaskRow(_ subtask: Subtask) -> some View {
        HStack(spacing: Spacing.sm) {
            // Checkbox
            Button(action: {
                viewModel.toggleSubtask(id: subtask.id)
            }) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(subtask.isCompleted ? Color.appSuccess : Color.textSecondary)
            }
            
            // Title (Editable)
            if editingSubtaskId == subtask.id {
                TextField("Subtask", text: Binding(
                    get: { subtask.title },
                    set: { viewModel.updateSubtask(id: subtask.id, title: $0) }
                ))
                .font(Typography.bodyRegular)
                .textFieldStyle(.plain)
                .onSubmit {
                    editingSubtaskId = nil
                }
            } else {
                Text(subtask.title)
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textPrimary)
                    .strikethrough(subtask.isCompleted)
                    .onTapGesture {
                        editingSubtaskId = subtask.id
                    }
            }
            
            Spacer()
            
            // Delete Button
            Button(action: {
                viewModel.deleteSubtask(id: subtask.id)
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appDestructive)
            }
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Notifications")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            Toggle(isOn: $viewModel.task.notifyOnChanges) {
                HStack(spacing: Spacing.sm) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appPrimary)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notify on Changes")
                            .font(Typography.bodyRegular)
                            .foregroundStyle(Color.textPrimary)
                        
                        Text("Get notified when collaborators make changes")
                            .font(Typography.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .tint(Color.appPrimary)
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var collaboratorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Collaborators")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            // Existing Collaborators
            if !viewModel.task.collaborators.isEmpty {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.task.collaborators, id: \.self) { email in
                        collaboratorRow(email: email)
                    }
                }
            }
            
            // Add Collaborator Field
            HStack(spacing: Spacing.sm) {
                Image(systemName: "envelope")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("Enter collaborator email...", text: $collaboratorEmail)
                    .font(Typography.bodyRegular)
                    .textFieldStyle(.plain)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onSubmit {
                        addCollaborator()
                    }
                
                if !collaboratorEmail.isEmpty {
                    Button(action: addCollaborator) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(12)
            
            // Info Text
            Text("Up to 3 collaborators on free plan")
                .font(Typography.caption)
                .foregroundStyle(Color.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private func collaboratorRow(email: String) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color.appPrimary)
            
            Text(email)
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            Button(action: {
                viewModel.removeCollaborator(email: email)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func addCollaborator() {
        guard !collaboratorEmail.isEmpty else { return }
        
        // Check if already at limit
        if viewModel.task.collaborators.count >= 3 {
            showPremiumBanner = true
            return
        }
        
        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: collaboratorEmail) else {
            return
        }
        
        // Add collaborator
        viewModel.addCollaborator(email: collaboratorEmail)
        collaboratorEmail = ""
    }
    
    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            HStack {
                Image(systemName: "trash")
                Text("Delete Task")
            }
            .font(Typography.bodyMedium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .background(Color.appDestructive)
            .cornerRadius(12)
        }
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Success Banner

struct SuccessBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
            Text(message)
                .font(Typography.bodyRegular)
        }
        .foregroundStyle(.white)
        .padding(Spacing.md)
        .background(Color.appSuccess)
        .cornerRadius(12)
        .shadow(radius: 8)
        .padding(.horizontal, Spacing.lg)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TaskDetailView(
            task: TaskItem(
                userId: "test",
                title: "Favorite UX Book",
                description: "Lean UX: Applying Lean Principles to Improve User Experience.",
                category: .design,
                color: "#DDD6FE",
                subtasks: [
                    Subtask(title: "Read Chapter 1", isCompleted: true),
                    Subtask(title: "Take Notes", isCompleted: false)
                ],
                dueDate: Date().timeIntervalSince1970
            )
        )
    }
}
