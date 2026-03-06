//
//  GreetingCard.swift
//  ToDoList
//
//  Created by Jollibe Dablo - INTERN on 3/6/26.
//

import SwiftUI

struct GreetingCard: View {
    // MARK: - Properties
    
    let userName: String
    @State private var gradientOffset: CGFloat = 0
    
    private let pastelColors: [Color] = [
        Color(hex: "#DDD6FE"), // Lavender
        Color(hex: "#FED7D7"), // Coral
        Color(hex: "#FEF3C7"), // Yellow
        Color(hex: "#D1FAE5"), // Mint
        Color(hex: "#BFDBFE"), // Sky
        Color(hex: "#E9D5FF"), // Purple
        Color(hex: "#FED7AA"), // Peach
        Color(hex: "#F3E8FF")  // Lilac
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground(colors: pastelColors, offset: gradientOffset)
                .blur(radius: 40)
            
            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(greetingText)
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.white.opacity(0.9))
                
                Text("Welcome, \(userName)! 👋")
                    .font(Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        .onAppear {
            withAnimation(
                .linear(duration: 8)
                .repeatForever(autoreverses: false)
            ) {
                gradientOffset = 1.0
            }
        }
    }
    
    // MARK: - Helpers
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    let colors: [Color]
    let offset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<colors.count, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 200, height: 200)
                        .offset(
                            x: circleOffset(index: index, in: geometry.size).x,
                            y: circleOffset(index: index, in: geometry.size).y
                        )
                        .blur(radius: 30)
                }
            }
        }
    }
    
    private func circleOffset(index: Int, in size: CGSize) -> CGPoint {
        let angleInDegrees = Double(index) * 45.0 + Double(offset) * 360.0
        let angle = Angle.degrees(angleInDegrees).radians
        let radius = min(size.width, size.height) * 0.4
        
        let baseX = size.width / 2
        let baseY = size.height / 2
        
        let x = baseX + CGFloat(cos(angle)) * radius
        let y = baseY + CGFloat(sin(angle)) * radius
        
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        GreetingCard(userName: "Alex")
        
        GreetingCard(userName: "Jordan")
    }
    .padding()
    .background(Color.appBackground)
}
