//
//  SearchBar.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct SearchBar: View {
    // MARK: - Properties
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @FocusState private var isFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Search Field
            HStack(spacing: Spacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textTertiary)
                
                TextField("Search tasks...", text: $searchText)
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textPrimary)
                    .focused($isFocused)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isSearching = true
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.textTertiary)
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.appSurface)
            .cornerRadius(12)
            
            // Cancel button when searching
            if isSearching {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        searchText = ""
                        isSearching = false
                        isFocused = false
                    }
                }) {
                    Text("Cancel")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.appPrimary)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .onChange(of: isSearching) { _, newValue in
            if newValue {
                isFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SearchBar(searchText: .constant(""), isSearching: .constant(false))
        SearchBar(searchText: .constant("UX Design"), isSearching: .constant(true))
    }
    .padding()
    .background(Color.appBackground)
}
