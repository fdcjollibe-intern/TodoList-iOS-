//
//  View+Modifiers.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//
import SwiftUI

extension View {
    /// Applies card style with shadow and rounded corners
    func cardStyle(
        backgroundColor: Color = .appSurface,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        shadowOpacity: Double = 0.08
    ) -> some View {
        self
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 4)
    }
    
    /// Hides the keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Adds a keyboard dismiss toolbar
    func keyboardDismissToolbar() -> some View {
        self.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
            }
        }
    }
}
