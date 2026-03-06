//
//  CategoryView.swift
//  ToDoList
//
//  Created on 2024.
//

import SwiftUI

struct CategoryView: View {
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showAddCategory = false
    @State private var newCategoryName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Categories Grid
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    categoriesGrid
                    
                    Spacer(minLength: Spacing.xxl)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.lg)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Categories")
                .font(Typography.title1)
                .foregroundStyle(Color.textPrimary)
            
            Text("Organize your tasks")
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.lg)
        .padding(.bottom, Spacing.md)
    }
    
    private var categoriesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: Spacing.md),
            GridItem(.flexible(), spacing: Spacing.md)
        ], spacing: Spacing.md) {
            // Add New Category Button (First)
            addNewCategoryButton
            
            // Existing Categories
            ForEach(TaskCategory.allCases, id: \.self) { category in
                categoryCard(category)
            }
        }
    }
    
    private var addNewCategoryButton: some View {
        Button(action: {
            showAddCategory = true
        }) {
            VStack(spacing: Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.appPrimary)
                }
                
                Text("Add New")
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textPrimary)
                
                Text("Create category")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(Color.appSurface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.appPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
        .alert("Coming Soon", isPresented: $showAddCategory) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Custom categories will be available in a future update.")
        }
    }
    
    private func categoryCard(_ category: TaskCategory) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = selectedCategory == category ? nil : category
            }
        }) {
            VStack(spacing: Spacing.md) {
                // Category Icon
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(category.color)
                }
                
                // Category Name
                Text(category.displayName)
                    .font(Typography.bodyMedium)
                    .foregroundStyle(Color.textPrimary)
                
                // Task Count (placeholder)
                Text("0 tasks")
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(
                selectedCategory == category ? 
                    category.color.opacity(0.1) : Color.appSurface
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedCategory == category ? 
                            category.color : Color.clear,
                        lineWidth: 2
                    )
            )
        }
    }
}

// Extension to add UI properties to TaskCategory
#Preview {
    CategoryView()
}
