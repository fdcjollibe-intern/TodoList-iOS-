//
//  LoadingOverlay.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct LoadingOverlay: View {
    // MARK: - Properties
    
    var message: String? = nil
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .appPrimary))
                    .scaleEffect(1.5)
                
                if let message = message {
                    Text(message)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.textPrimary)
                }
            }
            .padding(Spacing.xxl)
            .background(Color.appSurface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        
        LoadingOverlay(message: "Loading...")
    }
}
