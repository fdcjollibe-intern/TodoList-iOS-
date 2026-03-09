// Features/Home/Views/HomeView.swift

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    // MARK: - Properties
    
    @State private var viewModel: HomeViewModel?
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var showAllInProgress = false
    @State private var showAllCompleted = false
    
    private var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    private var userName: String {
        viewModel?.currentUser?.displayName ?? currentUser?.displayName ?? currentUser?.email?.components(separatedBy: "@").first ?? "User"
    }
    
    private var userInitials: String {
        viewModel?.currentUser?.initials ?? String(userName.prefix(1)).uppercased()
    }
    
    private var userProfileColor: Color {
        if let profilePhoto = viewModel?.currentUser?.profilePhoto {
            return Color(hex: profilePhoto)
        }
        return Color.appPrimary.opacity(0.2)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()
                
                // Modern Home Content
                modernHomeContent
                
                // Floating Create New Button
                Button(action: {
                    showAddTask = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.appPrimary.opacity(0.4), radius: 12, y: 6)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.trailing, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }
            .ignoresSafeArea(.keyboard)
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
            .navigationDestination(isPresented: $showAllInProgress) {
                AllTasksView(
                    title: "On Progress Tasks",
                    tasks: inProgressTasks
                )
            }
            .navigationDestination(isPresented: $showAllCompleted) {
                AllTasksView(
                    title: "Completed Tasks",
                    tasks: completedTasks
                )
            }
        }
        .onChange(of: selectedTask) { oldValue, newValue in
            // Reload tasks when navigating back from detail view
            if oldValue != nil && newValue == nil {
                Task {
                    await viewModel?.loadTasks()
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView {
                // Reload tasks after creation
                Task {
                    await viewModel?.loadTasks()
                }
            }
        }
        .task {
            // Initialize viewModel with current user ID
            if viewModel == nil, let userId = currentUser?.uid {
                viewModel = HomeViewModel(userId: userId)
                await viewModel?.loadUserProfile()
                await viewModel?.loadTasks()
            }
        }
    }
    
    // MARK: - Modern Home Content
    
    private var modernHomeContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: Spacing.lg) {
                // User Profile Header
                profileHeader
                    .padding(.top, Spacing.sm)
                
                // On Progress Section
                onProgressSection
                
                // Completed Section
                completedSection
                
                // Bottom padding for floating button
                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
    
    // MARK: - View Components
    
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                // User Avatar
                Group {
                    if let photoURL = viewModel?.currentUser?.profilePhoto, photoURL.hasPrefix("http") {
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ZStack {
                                Circle()
                                    .fill(userProfileColor)
                                Text(userInitials)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(userProfileColor)
                                .frame(width: 50, height: 50)
                            
                            Text(userInitials)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hello")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textSecondary)
                    
                    Text(userName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                }
                
                Spacer()
                
                HStack(spacing: Spacing.sm) {
                    // Globe Button
                    Button(action: {}) {
                        Image(systemName: "globe")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    // Notification Button
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.textSecondary)
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            
            // Search Bar
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textSecondary)
                
                TextField("Search tasks...", text: $searchText)
                    .font(.system(size: 15))
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
        }
    }
    
    private var onProgressSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("On Progress")
                    .font(Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Text("(\(inProgressTasks.count))")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                
                Spacer()
                
                Button(action: {
                    showAllInProgress = true
                }) {
                    Text("View More")
                        .font(Typography.caption)
                        .foregroundStyle(Color.appPrimary)
                }
            }
            
            if inProgressTasks.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No tasks in progress",
                    subtitle: "Create a new task to get started"
                )
                .padding(.vertical, Spacing.xl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(inProgressTasks.prefix(5)) { task in
                            ModernTaskCard(task: task) {
                                selectedTask = task
                            }
                            .frame(width: 280)
                        }
                    }
                }
            }
        }
    }
    
    private var completedSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Completed")
                    .font(Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.textPrimary)
                
                Spacer()
                
                Button(action: {
                    showAllCompleted = true
                }) {
                    Text("View More")
                        .font(Typography.caption)
                        .foregroundStyle(Color.appPrimary)
                }
            }
            
            if completedTasks.isEmpty {
                Text("No completed tasks yet")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, Spacing.md)
            } else {
                ForEach(completedTasks.prefix(3)) { task in
                    CompletedTaskRow(task: task) {
                        selectedTask = task
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var allTasks: [TaskItem] {
        let tasks = viewModel?.tasks ?? []
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { task in
            task.title.localizedCaseInsensitiveContains(searchText) ||
            (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    private var inProgressTasks: [TaskItem] {
        allTasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [TaskItem] {
        allTasks.filter { $0.isCompleted }
    }
}

// MARK: - Modern Task Card

struct ModernTaskCard: View {
    let task: TaskItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Main Content
                VStack(alignment: .leading, spacing: Spacing.md) {
                    // Title
                    Text(task.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.textPrimary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    // Date
                    if let dueDate = task.dueDate {
                        Text(formatDate(dueDate))
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textPrimary)
                    }
                    
                    // Description
                    if let description = task.description {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Description :")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                            
                            Text(description)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    // Teams avatars section (always show to maintain consistent height)
                    HStack(spacing: 4) {
                        if !task.collaborators.isEmpty {
                            Text("Teams :")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.textSecondary)
                            
                            HStack(spacing: -8) {
                                ForEach(task.collaborators.prefix(4), id: \.self) { email in
                                    CollaboratorAvatar(email: email, size: 28)
                                }
                            }
                        } else {
                            // Empty spacer to maintain consistent height
                            Text("")
                                .font(.system(size: 13))
                                .frame(height: 28)
                        }
                    }
                    
                    // Priority Badge
                    HStack(spacing: 4) {
                        Image(systemName: task.priority.icon)
                            .font(.system(size: 11))
                        Text(task.priority.displayName)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(task.priority.color)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.lg)
                .padding(.trailing, 44) // Extra padding for the circular icon
                
                // Color Bar at Bottom
                Rectangle()
                    .fill(Color(hex: task.color))
                    .frame(height: 6)
            }
            .background(
                ZStack {
                    Color.white
                    Color(hex: task.color).opacity(0.08)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.06), radius: 10, y: 3)
            .overlay(alignment: .topTrailing) {
                // Category Icon Circle (top right of card)
                Circle()
                    .fill(Color(hex: task.color))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: task.category == .personal ? "person.fill" : "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    )
                    .padding([.top, .trailing], Spacing.md)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getCollaboratorInitials(email: String) -> String {
        let username = email.components(separatedBy: "@").first ?? email
        let components = username.components(separatedBy: ".")
        if components.count > 1 {
            let first = String(components[0].prefix(1)).uppercased()
            let last = String(components[1].prefix(1)).uppercased()
            return first + last
        }
        return String(username.prefix(2)).uppercased()
    }
    
    private func getCollaboratorColor(email: String) -> Color {
        // Generate a consistent color based on email hash
        let hash = abs(email.hashValue)
        let colors: [String] = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
            "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2",
            "#F8B739", "#52B788", "#A166AB", "#F4A261"
        ]
        let index = hash % colors.count
        return Color(hex: colors[index])
    }
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        
        // Check if date is today
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today, \(formatFullDate(date))"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow, \(formatFullDate(date))"
        } else {
            formatter.dateFormat = "EEEE, dd MMMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Completed Task Row

struct CompletedTaskRow: View {
    let task: TaskItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Left color indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(hex: task.color))
                    .frame(width: 5)
                
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            // Title
                            Text(task.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                                .lineLimit(1)
                            
                            // Description/subtitle
                            if let description = task.description {
                                Text(description)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.textSecondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                        
                        // Checkmark
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    
                    // Date/Time and Collaborators
                    HStack {
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Text("Today")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textTertiary)
                                
                                Text(formatTime(dueDate))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.textTertiary)
                            }
                        }
                        
                        Spacer()
                        
                        // Collaborators
                        if !task.collaborators.isEmpty {
                            HStack(spacing: -6) {
                                ForEach(task.collaborators.prefix(2), id: \.self) { email in
                                    CollaboratorAvatar(email: email, size: 24)
                                }
                            }
                        }
                    }
                }
                .padding(.leading, Spacing.md)
                .padding(.vertical, Spacing.md)
                .padding(.trailing, Spacing.md)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func getCollaboratorInitials(email: String) -> String {
        let username = email.components(separatedBy: "@").first ?? email
        let components = username.components(separatedBy: ".")
        if components.count > 1 {
            let first = String(components[0].prefix(1)).uppercased()
            let last = String(components[1].prefix(1)).uppercased()
            return first + last
        }
        return String(username.prefix(2)).uppercased()
    }
    
    private func getCollaboratorColor(email: String) -> Color {
        let hash = abs(email.hashValue)
        let colors: [String] = [
            "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
            "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2"
        ]
        let index = hash % colors.count
        return Color(hex: colors[index])
    }
}

// MARK: - Scroll Offset Preference Key

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
