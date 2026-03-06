//
//  PremiumBanner.swift
//  ToDoList
//
//  Created on 2024.
//

import SwiftUI

struct PremiumBanner: View {
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dimmed Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Banner Card
            VStack(spacing: Spacing.lg) {
                // Premium Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.2), Color.appSecondary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, Spacing.md)
                
                // Title
                Text("Upgrade to Premium")
                    .font(Typography.title2)
                    .foregroundStyle(Color.textPrimary)
                
                // Description
                Text("Unlock unlimited collaborators and more premium features")
                    .font(Typography.bodyRegular)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
                
                // Pricing Options
                VStack(spacing: Spacing.md) {
                    PricingOption(
                        title: "Monthly",
                        price: "$19",
                        period: "per month",
                        isRecommended: false
                    )
                    
                    PricingOption(
                        title: "Lifetime",
                        price: "$199",
                        period: "one-time payment",
                        isRecommended: true
                    )
                }
                .padding(.horizontal, Spacing.lg)
                
                // Coming Soon Button
                Button(action: {
                    // Show alert that premium is coming soon
                    dismiss()
                }) {
                    Text("Coming Soon")
                        .font(Typography.bodyMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, Spacing.lg)
                
                // Close Button
                Button("Maybe Later") {
                    dismiss()
                }
                .font(Typography.bodyRegular)
                .foregroundStyle(Color.textSecondary)
                .padding(.bottom, Spacing.md)
            }
            .frame(maxWidth: 340)
            .background(Color.appSurface)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 20, y: 10)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct PricingOption: View {
    let title: String
    let price: String
    let period: String
    let isRecommended: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(Typography.bodyMedium)
                        .foregroundStyle(Color.textPrimary)
                    
                    if isRecommended {
                        Text("BEST VALUE")
                            .font(Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.appSuccess)
                            .cornerRadius(4)
                    }
                }
                
                Text(period)
                    .font(Typography.caption)
                    .foregroundStyle(Color.textSecondary)
            }
            
            Spacer()
            
            Text(price)
                .font(Typography.title3)
                .foregroundStyle(Color.appPrimary)
        }
        .padding(Spacing.md)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRecommended ? Color.appPrimary : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    PremiumBanner(isPresented: .constant(true))
}
