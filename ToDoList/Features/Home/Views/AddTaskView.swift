//
//  AddTaskView.swift
//  ToDoList
//
//  Created on 2024.
//

import SwiftUI
import FirebaseAuth

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddTaskViewModel
    let onTaskCreated: (() -> Void)?
    
    init(onTaskCreated: (() -> Void)? = nil) {
        let userId = Auth.auth().currentUser?.uid ?? ""
        _viewModel = State(initialValue: AddTaskViewModel(userId: userId))
        self.onTaskCreated = onTaskCreated
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: Spacing.lg) {
                    // Title Input
                    titleSection
                    
                    // Category Selection
                    categorySection
                    
                    // Priority Selection
                    prioritySection
                    
                    // Description Input
                    descriptionSection
                    
                    // Color Picker
                    colorSection
                    
                    // Date and Time
                    dateTimeSection
                    
                    // Collaborators
                    collaboratorsSection
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.lg)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.textPrimary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        Task {
                            if await viewModel.createTask() {
                                onTaskCreated?()
                                dismiss()
                            }
                        }
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.canCreate ? Color.appPrimary : Color.textTertiary)
                    .disabled(!viewModel.canCreate)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .overlay(alignment: .center) {
                if viewModel.showPremiumBanner {
                    PremiumBanner(isPresented: $viewModel.showPremiumBanner)
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Title Task")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            TextField("Add Task Name...", text: $viewModel.title)
                .font(Typography.bodyRegular)
                .padding(Spacing.md)
                .background(Color.appBackground)
                .cornerRadius(10)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Description (Optional)")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            TextField("Add Description...", text: $viewModel.description, axis: .vertical)
                .font(Typography.bodyRegular)
                .lineLimit(3...5)
                .padding(Spacing.md)
                .background(Color.appBackground)
                .cornerRadius(10)
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Category")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                // Personal Category
                Button(action: {
                    viewModel.selectedCategory = .personal
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                        Text("Personal")
                            .font(Typography.bodyMedium)
                    }
                    .foregroundStyle(viewModel.selectedCategory == .personal ? .white : Color.textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.selectedCategory == .personal ? Color.appPrimary : Color.appBackground)
                    .cornerRadius(10)
                }
                
                // Teams Category
                Button(action: {
                    viewModel.selectedCategory = .work
                }) {
                    HStack(spacing: Spacing.xs) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                        Text("Teams")
                            .font(Typography.bodyMedium)
                    }
                    .foregroundStyle(viewModel.selectedCategory == .work ? .white : Color.textPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(viewModel.selectedCategory == .work ? Color.appPrimary : Color.appBackground)
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Priority")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            HStack(spacing: Spacing.md) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Button(action: {
                        viewModel.selectedPriority = priority
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: priority.icon)
                                .font(.system(size: 14))
                            Text(priority.displayName)
                                .font(Typography.bodyMedium)
                        }
                        .foregroundStyle(viewModel.selectedPriority == priority ? .white : Color.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(viewModel.selectedPriority == priority ? priority.color : Color.appBackground)
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Color")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(ColorPalette.taskColors, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .strokeBorder(viewModel.selectedColor == color ? Color.appPrimary : Color.clear, lineWidth: 3)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .opacity(viewModel.selectedColor == color ? 1 : 0)
                            )
                            .onTapGesture {
                                viewModel.selectedColor = color
                            }
                    }
                }
            }
        }
    }
    
    private var dateTimeSection: some View {
        HStack(spacing: Spacing.md) {
            // Date Section
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Date")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textPrimary)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textSecondary)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.dueDate,
                        displayedComponents: [.date]
                    )
                    .labelsHidden()
                    .tint(Color.appPrimary)
                }
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(Color.appBackground)
                .cornerRadius(10)
            }
            
            // Time Section
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Time")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textPrimary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.textSecondary)
                    
                    DatePicker(
                        "",
                        selection: $viewModel.dueDate,
                        displayedComponents: [.hourAndMinute]
                    )
                    .labelsHidden()
                    .tint(Color.appPrimary)
                }
                .padding(Spacing.sm)
                .frame(maxWidth: .infinity)
                .background(Color.appBackground)
                .cornerRadius(10)
            }
        }
    }
    
    private var collaboratorsSection: some View {
        Group {
            if viewModel.selectedCategory == .work {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Collaborators")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Color.textPrimary)
                        
                        Spacer()
                        
                        Text("Up to 3 collaborators")
                            .font(Typography.caption)
                            .foregroundStyle(Color.textTertiary)
                    }
                    
                    // Email Input
                    HStack(spacing: Spacing.sm) {
                        TextField("Enter email address...", text: $viewModel.collaboratorEmail)
                            .font(Typography.bodyRegular)
                            .padding(Spacing.md)
                            .background(Color.appBackground)
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                        
                        Button(action: {
                            viewModel.addCollaborator()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(viewModel.collaboratorEmail.isEmpty ? Color.textTertiary : Color.appPrimary)
                        }
                        .disabled(viewModel.collaboratorEmail.isEmpty)
                    }
                    
                    // Collaborators List
                    if !viewModel.collaborators.isEmpty {
                        VStack(spacing: Spacing.sm) {
                            ForEach(viewModel.collaborators, id: \.self) { email in
                                HStack {
                                    CollaboratorAvatar(email: email, size: 28)
                                    
                                    Text(email)
                                        .font(Typography.bodyRegular)
                                        .foregroundStyle(Color.textPrimary)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        viewModel.removeCollaborator(email: email)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.textTertiary)
                                    }
                                }
                                .padding(Spacing.md)
                                .background(Color.appBackground)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct CategoryButton: View {
    let category: TaskCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.system(size: 14))
                Text(category.displayName)
                    .font(Typography.bodyRegular)
            }
            .foregroundStyle(isSelected ? .white : Color.textPrimary)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(isSelected ? Color.appPrimary : Color.appInputBackground)
            .cornerRadius(20)
        }
    }
}

struct ColorCircle: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .strokeBorder(isSelected ? Color.appPrimary : Color.clear, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }
}

// MARK: - ViewModel

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

#Preview {
    AddTaskView()
}
