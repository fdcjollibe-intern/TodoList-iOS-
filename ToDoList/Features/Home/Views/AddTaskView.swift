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
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.lg) {
                        // Title Input
                        titleSection
                        
                        // Description Input
                        descriptionSection
                        
                        // Category Selection
                        categorySection
                        
                        // Color Picker
                        colorSection
                        
                        // Due Date
                        dueDateSection
                        
                        // Collaborators
                        collaboratorsSection
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            if await viewModel.createTask() {
                                onTaskCreated?()
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canCreate)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(viewModel.canCreate ? Color.appPrimary : Color.textSecondary)
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
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Title")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            TextField("Enter task title...", text: $viewModel.title)
                .font(Typography.bodyRegular)
                .padding(Spacing.md)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Description (Optional)")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            TextField("Enter description...", text: $viewModel.description, axis: .vertical)
                .font(Typography.bodyRegular)
                .lineLimit(3...6)
                .padding(Spacing.md)
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Category")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    // Add New Category Button
                    Button(action: {
                        // Coming soon
                    }) {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                            Text("Add New")
                                .font(Typography.bodyRegular)
                        }
                        .foregroundStyle(Color.appPrimary)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.appPrimary.opacity(0.1))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.appPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3]))
                        )
                    }
                    
                    ForEach(TaskCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Color")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(ColorPalette.taskColors, id: \.self) { color in
                        ColorCircle(
                            color: color,
                            isSelected: viewModel.selectedColor == color
                        ) {
                            viewModel.selectedColor = color
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }
    
    private var dueDateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Due Date")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Toggle("", isOn: $viewModel.hasDueDate)
                    .labelsHidden()
                    .tint(Color.appPrimary)
            }
            
            if viewModel.hasDueDate {
                DatePicker(
                    "Select date",
                    selection: $viewModel.dueDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(Color.appPrimary)
                .padding(.top, Spacing.xs)
            }
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
    }
    
    private var collaboratorsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Collaborators (Optional)")
                .font(Typography.bodyMedium)
                .foregroundStyle(Color.textSecondary)
            
            // Existing Collaborators
            if !viewModel.collaborators.isEmpty {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.collaborators, id: \.self) { email in
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
                        .padding(Spacing.sm)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                }
            }
            
            // Add Collaborator Field
            HStack(spacing: Spacing.sm) {
                Image(systemName: "envelope.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("Enter email address...", text: $viewModel.collaboratorEmail)
                    .font(Typography.bodyRegular)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                if !viewModel.collaboratorEmail.isEmpty {
                    Button(action: {
                        viewModel.addCollaborator()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
            .padding(Spacing.md)
            .background(Color.white)
            .cornerRadius(12)
            
            // Info Text
            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                Text("Up to 3 collaborators on free plan")
                    .font(.system(size: 12))
            }
            .foregroundStyle(Color.textSecondary)
        }
        .padding(Spacing.lg)
        .background(Color.appSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, y: 2)
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
            subtasks: [],
            dueDate: hasDueDate ? dueDate.timeIntervalSince1970 : nil,
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
