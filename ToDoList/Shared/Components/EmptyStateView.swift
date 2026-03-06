//
//  EmptyStateView.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    
    let icon: String
    let title: String
    let subtitle: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(Color.textTertiary)
            
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(Typography.title3)
                    .foregroundStyle(Color.textPrimary)
                
                Text(subtitle)
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.xxl)
    }
}

// MARK: - Preview

#Preview {
    EmptyStateView(
        icon: "tray",
        title: "No Tasks Yet",
        subtitle: "Tap the + button to create your first task"
    )
    .background(Color.appBackground)
}
