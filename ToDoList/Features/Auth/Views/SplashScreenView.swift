//
//  SplashScreenView.swift
//  ToDoList
//
//  Created on 2024.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Turquoise Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: "#4ECDC4"),
                    Color(hex: "#44A08D")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // App Logo with Animation
                ZStack {
                    // Outer Circle with Glow
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                        .scaleEffect(scale * 1.2)
                    
                    // Main Logo Circle
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
                    
                    // Checkmark Icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#4ECDC4"),
                                    Color(hex: "#44A08D")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(rotationAngle))
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                // App Name
                VStack(spacing: Spacing.xs) {
                    Text("ToDoList")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("Stay organized, Stay productive")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .opacity(opacity)
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
