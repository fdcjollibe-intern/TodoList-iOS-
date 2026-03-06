// Shared/Components/TaskCard.swift

import SwiftUI

struct TaskCard: View {
    // MARK: - Properties
    
    let task: TaskItem
    let onTap: () -> Void
    
    // MARK: - Init
    
    init(task: TaskItem, onTap: @escaping () -> Void) {
        self.task = task
        self.onTap = onTap
    }
    
    // MARK: - Body
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Title
                Text(task.title)
                    .font(Typography.title3)
                    .foregroundStyle(Color.textPrimary)
                    .multilineTextAlignment(.leading)
                
                // Description
                if let description = task.description {
                    Text(description)
                        .font(Typography.caption)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Subtasks
                if !task.subtasks.isEmpty {
                    VStack(spacing: Spacing.sm) {
                        ForEach(task.subtasks.prefix(2)) { subtask in
                            HStack(spacing: Spacing.sm) {
                                Image(systemName: subtask.isCompleted ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 16))
                                    .foregroundStyle(subtask.isCompleted ? Color.appPrimary : Color.textTertiary)
                                
                                Text(subtask.title)
                                    .font(Typography.bodyRegular)
                                    .foregroundStyle(Color.textSecondary)
                                    .strikethrough(subtask.isCompleted)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, Spacing.xs)
                }
                
                Spacer()
                
                // Bottom Info
                HStack(spacing: Spacing.lg) {
                    // Date
                    if let dueDate = task.dueDate {
                        HStack(spacing: Spacing.xs) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(formatDate(dueDate))
                                .font(Typography.caption)
                        }
                        .foregroundStyle(Color.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Category Tag
                    Text(task.category.displayName)
                        .font(Typography.footnote)
                        .foregroundStyle(Color.textPrimary)
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(6)
                }
            }
            .padding(Spacing.lg)
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    // Card background with folder tab notch
                    FolderCardShape()
                        .fill(task.backgroundColor)
                    
                    // White border stroke on folder tab
                    FolderCardShape()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    
                    // Curved wave decoration in center
                    WaveShape()
                        .fill(Color.white.opacity(0.12))
                        .frame(height: 80)
                }
            )
            .compositingGroup()
        }
        .buttonStyle(CardButtonStyle())
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yy"
        return formatter.string(from: date)
    }
}

// MARK: - Folder Card Shape

struct FolderCardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let tabWidth: CGFloat = 80
        let tabHeight: CGFloat = 12
        let cornerRadius: CGFloat = 20
        let tabCornerRadius: CGFloat = 8
        
        // Start from bottom left corner
        path.move(to: CGPoint(x: cornerRadius, y: height))
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        // Top edge to folder tab start
        path.addLine(to: CGPoint(x: (width / 2) - (tabWidth / 2) - tabCornerRadius, y: 0))
        
        // Folder tab notch (centered at top)
        path.addArc(
            center: CGPoint(x: (width / 2) - (tabWidth / 2), y: 0),
            radius: tabCornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: (width / 2) - (tabWidth / 2), y: -tabHeight))
        path.addLine(to: CGPoint(x: (width / 2) + (tabWidth / 2), y: -tabHeight))
        path.addLine(to: CGPoint(x: (width / 2) + (tabWidth / 2), y: 0))
        
        path.addArc(
            center: CGPoint(x: (width / 2) + (tabWidth / 2), y: 0),
            radius: tabCornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Continue top edge
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        
        // Bottom right corner
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        
        return path
    }
}

// MARK: - Wave Shape

struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        // Start from left
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // Create smooth wave using quadratic curves
        path.addQuadCurve(
            to: CGPoint(x: width * 0.25, y: midHeight - 20),
            control: CGPoint(x: width * 0.125, y: midHeight - 20)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.5, y: midHeight),
            control: CGPoint(x: width * 0.375, y: midHeight + 20)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width * 0.75, y: midHeight - 20),
            control: CGPoint(x: width * 0.625, y: midHeight - 20)
        )
        
        path.addQuadCurve(
            to: CGPoint(x: width, y: midHeight),
            control: CGPoint(x: width * 0.875, y: midHeight + 20)
        )
        
        // Complete the shape
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        TaskCard(
            task: TaskItem(
                userId: "test",
                title: "Favorite UX Book",
                description: "Lean UX: Applying Lean Principles to Improve User Experience.",
                category: .design,
                color: "#DDD6FE",
                subtasks: []
            ),
            onTap: {}
        )
        
        TaskCard(
            task: TaskItem(
                userId: "test",
                title: "2024 Fashion Trend",
                description: nil,
                category: .lifestyle,
                color: "#FED7D7",
                subtasks: [
                    Subtask(title: "Men's Casual Dress", isCompleted: false),
                    Subtask(title: "Summer Styles", isCompleted: false)
                ]
            ),
            onTap: {}
        )
    }
    .padding()
    .background(Color.appBackground)
}
