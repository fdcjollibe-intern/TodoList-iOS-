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
    
    @State private var isEditMode = false
    @State private var showColorPicker = false
    @State private var showDatePicker = false
    @State private var showDeleteConfirmation = false
    @State private var collaboratorEmail = ""
    @State private var showPremiumBanner = false
    
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
                
                // Content
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Description Section
                        descriptionSection
                        
                        // Category & Priority Section
                        categoryPrioritySection
                        
                        // Color Section
                        colorSection
                        
                        // Due Date Section
                        dueDateSection
                        
                        // Notification Toggle
                        notificationSection
                        
                        // Collaborators Section
                        collaboratorsSection
                        
                        // Delete Button
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
                    if isEditMode {
                        Task {
                            await viewModel.updateTask()
                        }
                    }
                    isEditMode.toggle()
                }) {
                    Text(isEditMode ? "Done" : "Edit")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                }
                .disabled(isEditMode && !viewModel.canSave)
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
    
    private var taskHeaderCard: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Title
            if isEditMode {
                TextField("Task title", text: $viewModel.task.title, axis: .vertical)
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                    .textFieldStyle(.plain)
                    .padding(Spacing.sm)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
            } else {
                Text(viewModel.task.title)
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Status Toggle (always enabled)
            Button(action: {
                Task {
                    await viewModel.toggleCompletion()
                }
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
            
            if isEditMode {
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
            } else {
                if let description = viewModel.task.description, !description.isEmpty {
                    Text(description)
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textPrimary)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                } else {
                    Text("No description")
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textSecondary)
                        .italic()
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private var categoryPrioritySection: some View {
        Group {
            if isEditMode {
                // Edit Mode: Separate rows for each
                VStack(spacing: Spacing.lg) {
                    // Category
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
                    
                    // Priority
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Priority")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.textSecondary)
                        
                        HStack(spacing: Spacing.md) {
                            ForEach(TaskPriority.allCases, id: \.self) { priority in
                                Button(action: {
                                    viewModel.updatePriority(priority)
                                }) {
                                    HStack(spacing: Spacing.xs) {
                                        Image(systemName: priority.icon)
                                            .font(.system(size: 12))
                                        Text(priority.displayName)
                                            .font(Typography.caption)
                                    }
                                    .foregroundStyle(viewModel.task.priority == priority ? .white : Color.textPrimary)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.sm)
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.task.priority == priority ? priority.color : Color.appBackground)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding(Spacing.lg)
                .cardStyle()
            } else {
                // View Mode: Side by side
                HStack(alignment: .top, spacing: Spacing.md) {
                    // Category
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Category")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.textSecondary)
                        
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: viewModel.task.category.icon)
                                .font(.system(size: 16))
                            Text(viewModel.task.category.displayName)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.textPrimary)
                        .padding(Spacing.sm)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Priority
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Priority")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.textSecondary)
                        
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: viewModel.task.priority.icon)
                                .font(.system(size: 16))
                            Text(viewModel.task.priority.displayName)
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(.white)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.task.priority.color)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(Spacing.lg)
                .cardStyle()
            }
        }
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Card Color")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            if isEditMode {
                Button(action: { showColorPicker = true }) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hex: viewModel.task.color))
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.appBorder, lineWidth: 1)
                            )
                        
                        Text("Change Color")
                            .font(Typography.bodyRegular)
                            .foregroundStyle(Color.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                    }
                    .padding(Spacing.md)
                    .background(Color.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            } else {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: viewModel.task.color))
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.appBorder, lineWidth: 1)
                        )
                    
                    Text(viewModel.task.color)
                        .font(Typography.bodyRegular)
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
                
                if isEditMode && viewModel.task.dueDate != nil {
                    Button(action: {
                        viewModel.updateDueDate(nil)
                    }) {
                        Text("Clear")
                            .font(Typography.caption)
                            .foregroundStyle(Color.appDestructive)
                    }
                }
            }
            
            if isEditMode {
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
            } else {
                if let dueDate = viewModel.task.dueDate {
                    Text(formatDueDate(dueDate))
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textPrimary)
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                } else {
                    Text("No due date set")
                        .font(Typography.bodyRegular)
                        .foregroundStyle(Color.textSecondary)
                        .italic()
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private func formatDueDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
            .disabled(!isEditMode)
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
            } else if !isEditMode {
                Text("No collaborators")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .italic()
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            // Add Collaborator Field (only in edit mode)
            if isEditMode {
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
        }
        .padding(Spacing.lg)
        .cardStyle()
    }
    
    private func collaboratorRow(email: String) -> some View {
        HStack(spacing: Spacing.sm) {
            CollaboratorAvatar(email: email, size: 32)
            
            Text(email)
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textPrimary)
            
            Spacer()
            
            if isEditMode {
                Button(action: {
                    viewModel.removeCollaborator(email: email)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.textSecondary)
                }
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
                dueDate: Date().timeIntervalSince1970
            )
        )
    }
}
