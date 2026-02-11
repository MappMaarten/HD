//
//  CircularIconView.swift
//  HD
//
//  Decorative circular icon with concentric rings and animated fade-in
//

import SwiftUI

struct CircularIconView: View {
    let icon: String
    var size: CGFloat = 200
    var animateRings: Bool = false
    var ringColor: Color = HDColors.sageGreen
    var iconColor: Color = HDColors.forestGreen

    // Animation states for ring fade-in
    @State private var ring1Opacity: Double = 0
    @State private var ring2Opacity: Double = 0
    @State private var ring3Opacity: Double = 0

    // Proportional sizes (calculated as % of size)
    private var outerCircleSize: CGFloat { size }
    private var middleCircleSize: CGFloat { size * 0.75 }
    private var innerCircleSize: CGFloat { size * 0.5 }
    private var iconSize: CGFloat { size * 0.2 }

    var body: some View {
        ZStack {
            // Outer circle with gradient (fades in first)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            ringColor.opacity(0.3),
                            ringColor.opacity(0.1)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: outerCircleSize / 2
                    )
                )
                .frame(width: outerCircleSize, height: outerCircleSize)
                .opacity(ring1Opacity)
                .shadow(color: ringColor.opacity(0.3), radius: 10)

            // Middle circle (fades in second)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            ringColor.opacity(0.35),
                            ringColor.opacity(0.18)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: middleCircleSize / 2
                    )
                )
                .frame(width: middleCircleSize, height: middleCircleSize)
                .opacity(ring2Opacity)

            // Inner circle (fades in last)
            Circle()
                .fill(ringColor)
                .frame(width: innerCircleSize, height: innerCircleSize)
                .opacity(ring3Opacity)

            // Central icon
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(iconColor)
                .opacity(ring3Opacity)
        }
        .frame(width: size, height: size)
        .onAppear {
            if animateRings {
                // Reset opacities first
                ring1Opacity = 0
                ring2Opacity = 0
                ring3Opacity = 0

                // Animate rings fading in sequentially
                withAnimation(.easeOut(duration: 0.4)) {
                    ring1Opacity = 1
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.15)) {
                    ring2Opacity = 1
                }
                withAnimation(.easeOut(duration: 0.4).delay(0.3)) {
                    ring3Opacity = 1
                }
            } else {
                // Show immediately without animation
                ring1Opacity = 1
                ring2Opacity = 1
                ring3Opacity = 1
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        CircularIconView(icon: "figure.hiking", animateRings: true)

        CircularIconView(
            icon: "leaf.fill",
            size: 120,
            animateRings: false
        )

        CircularIconView(
            icon: "camera.fill",
            size: 80
        )
    }
    .padding()
    .background(HDColors.cream)
}
