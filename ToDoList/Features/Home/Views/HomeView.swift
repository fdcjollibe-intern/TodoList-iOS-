// Features/Home/Views/HomeView.swift

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    // MARK: - Properties
    
    @State private var viewModel: HomeViewModel?
    @State private var selectedCategory: TaskCategory? = nil
    @State private var selectedTab: Tab = .home
    @State private var showAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var scrollOffset: CGFloat = 0
    @State private var isBrowseMode = false // Toggle for folder browsing mode
    @State private var searchText = ""
    @State private var isSearching = false
    
    private var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }
    
    private var userName: String {
        currentUser?.displayName ?? currentUser?.email?.components(separatedBy: "@").first ?? "User"
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color.appBackground.ignoresSafeArea()
                
                // Content based on selected tab
                if selectedTab == .calendar {
                    CalendarView()
                } else if selectedTab == .category {
                    CategoryView()
                } else if selectedTab == .settings {
                    SettingsView()
                } else {
                    VStack(spacing: 0) {
                        // Header Title
                        headerTitle
                        
                        // Search Bar with Toggle
                        topNavigationBar
                        
                        // Card content with smooth animation
                        if !isSearching {
                            taskCardsSection
                        } else {
                            // Search results
                            taskCardsSection
                                .transition(.opacity)
                        }
                    }
                }
                
                // Bottom Navigation
                bottomNavigationBar
            }
            .ignoresSafeArea(.keyboard)
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailView(task: task)
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
                await viewModel?.loadTasks()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerTitle: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("ToDoList")
                .font(Typography.title1)
                .foregroundStyle(Color.appPrimary.opacity(0.8))
            
            Text("Welcome, \(userName)")
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xs)
    }
    
    private var topNavigationBar: some View {
        HStack(spacing: Spacing.md) {
            // Search Bar
            SearchBar(searchText: $searchText, isSearching: $isSearching)
            
            // Browse Mode Toggle (only show when not searching)
            if !isSearching {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isBrowseMode.toggle()
                    }
                }) {
                    Image(systemName: isBrowseMode ? "square.stack.3d.up.fill" : "square.stack.3d.up")
                        .font(.system(size: 20))
                        .foregroundStyle(isBrowseMode ? Color.appPrimary : Color.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Color.appSurface)
                        .cornerRadius(12)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }
    
    private var taskCardsSection: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: isBrowseMode ? -30 : Spacing.md) {
                ForEach(Array(filteredTasks.enumerated()), id: \.element.id) { index, task in
                    TaskCard(task: task) {
                        selectedTask = task
                    }
                    .rotation3DEffect(
                        .degrees(isBrowseMode ? getCardRotation(index: index) : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .bottom,
                        perspective: 0.3
                    )
                    .scaleEffect(isBrowseMode ? getCardScale(index: index) : 1.0)
                    .offset(y: isBrowseMode ? getCardOffset(index: index) : getDefaultCardOffset(index: index))
                    .zIndex(isBrowseMode ? Double(filteredTasks.count - index) : Double(index))
                    .shadow(
                        color: .black.opacity(isBrowseMode ? getCardShadowOpacity(index: index) : 0.08),
                        radius: isBrowseMode ? getCardShadowRadius(index: index) : 8,
                        x: 0,
                        y: isBrowseMode ? getCardShadowY(index: index) : 4
                    )
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.md)
            .padding(.bottom, 100) // Space for bottom nav
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: proxy.frame(in: .named("scroll")).minY
                    )
                }
            )
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
    
    private var bottomNavigationBar: some View {
        ZStack {
            // Floating navigation container
            HStack(spacing: 0) {
                // Home Tab
                TabButton(
                    icon: "house.fill",
                    title: "Home",
                    isSelected: selectedTab == .home
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .home
                    }
                }
                
                // Calendar Tab
                TabButton(
                    icon: "calendar.circle.fill",
                    title: "Calendar",
                    isSelected: selectedTab == .calendar
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .calendar
                    }
                }
                
                // Spacer for center button
                Spacer()
                    .frame(width: 80)
                
                // Category Tab
                TabButton(
                    icon: "square.grid.2x2.fill",
                    title: "Category",
                    isSelected: selectedTab == .category
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .category
                    }
                }
                
                // Settings Tab
                TabButton(
                    icon: "person.circle.fill",
                    title: "Profile",
                    isSelected: selectedTab == .settings
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .settings
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appSurface)
                    .shadow(color: Color.black.opacity(0.08), radius: 20, y: -5)
            )
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            
            // Center Add Button (floating above)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    showAddTask = true
                }
            }) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: Color.appPrimary.opacity(0.4), radius: 16, y: 8)
            }
            .offset(y: -32)
        }
        .frame(height: 90)
    }
    
    // MARK: - Computed Properties
    
    private var filteredTasks: [TaskItem] {
        var tasks = viewModel?.tasks ?? []
        
        // Filter by search text
        if !searchText.isEmpty {
            tasks = tasks.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                (task.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by selected category
        if let selectedCategory = selectedCategory {
            tasks = tasks.filter { $0.category == selectedCategory }
        }
        
        return tasks
    }
    
    // MARK: - 3D Card Animation Helpers
    
    // Default mode: simple deck stacking (first card at bottom)
    private func getDefaultCardOffset(index: Int) -> CGFloat {
        // No dynamic offset in default mode - just natural scroll
        return 0
    }
    
    // Browse mode: folder drawer effect
    private func getCardRotation(index: Int) -> Double {
        let baseRotation: CGFloat = 3.0 // Base slant for folder drawer effect (positive = top tilts toward viewer)
        let cardPosition = CGFloat(index) * 50
        let scrollInfluence = (scrollOffset + cardPosition) / 80
        let dynamicRotation = min(max(scrollInfluence, -8), 8)
        return Double(baseRotation + dynamicRotation)
    }
    
    private func getCardScale(index: Int) -> CGFloat {
        let cardPosition = CGFloat(index) * 50
        let adjustedOffset = scrollOffset + cardPosition
        
        // Scale cards slightly as they move
        let scaleFactor = abs(adjustedOffset) / 800
        let scale = 1 - min(scaleFactor, 0.08)
        
        return scale
    }
    
    private func getCardOffset(index: Int) -> CGFloat {
        let cardPosition = CGFloat(index) * 50
        let adjustedOffset = scrollOffset + cardPosition
        
        // Create vertical offset for depth layering
        // Increased base offset to ensure second card is visible
        let baseOffset = CGFloat(index) * 20 // Increased from 8 to 20 for better visibility
        let scrollOffset = min(max(adjustedOffset / 12, -30), 30)
        
        return baseOffset + scrollOffset
    }
    
    private func getCardShadowOpacity(index: Int) -> Double {
        let cardPosition = CGFloat(index) * 50
        let adjustedOffset = scrollOffset + cardPosition
        
        // Increase shadow opacity for depth
        let baseOpacity = 0.15 + (Double(index) * 0.02)
        let scrollOpacity = Double(min(max(abs(adjustedOffset) / 500, 0), 0.1))
        
        return min(baseOpacity + scrollOpacity, 0.3)
    }
    
    private func getCardShadowRadius(index: Int) -> CGFloat {
        let cardPosition = CGFloat(index) * 50
        let adjustedOffset = scrollOffset + cardPosition
        
        // Larger shadow for cards further back
        let baseShadow: CGFloat = 12 + CGFloat(index) * 2
        let scrollShadow = min(abs(adjustedOffset) / 40, 8)
        
        return baseShadow + scrollShadow
    }
    
    private func getCardShadowY(index: Int) -> CGFloat {
        let cardPosition = CGFloat(index) * 50
        let adjustedOffset = scrollOffset + cardPosition
        
        // Shadow Y offset for realistic depth
        let baseShadowY: CGFloat = 4 + CGFloat(index) * 1.5
        let scrollShadowY = min(max(adjustedOffset / 30, -6), 6)
        
        return baseShadowY + scrollShadowY
    }
}

// MARK: - Tab Enum

enum Tab {
    case home, calendar, category, settings
}

// MARK: - Tab Button Component

struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(
                        isSelected 
                        ? LinearGradient(
                            colors: [Color.appPrimary, Color.appSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.textTertiary, Color.textTertiary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
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
