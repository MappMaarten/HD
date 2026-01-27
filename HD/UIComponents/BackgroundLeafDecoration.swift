//
//  BackgroundLeafDecoration.swift
//  HD
//
//  Subtle decorative leaf icon for background decoration
//

import SwiftUI

struct BackgroundLeafDecoration: View {
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let xOffset: CGFloat
    let yOffset: CGFloat

    var body: some View {
        GeometryReader { geometry in
            Image(systemName: "leaf.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(HDColors.sageGreen)
                .opacity(opacity)
                .rotationEffect(.degrees(rotation))
                .position(
                    x: xOffset >= 0 ? xOffset : geometry.size.width + xOffset,
                    y: yOffset >= 0 ? yOffset : geometry.size.height + yOffset
                )
        }
    }
}

#Preview {
    ZStack {
        HDColors.cream.ignoresSafeArea()

        // Top-left leaf
        BackgroundLeafDecoration(
            size: 120,
            rotation: 15,
            opacity: 0.10,
            xOffset: 60,
            yOffset: 80
        )

        // Top-right leaf
        BackgroundLeafDecoration(
            size: 100,
            rotation: -20,
            opacity: 0.08,
            xOffset: -60,
            yOffset: 120
        )

        // Bottom-left leaf
        BackgroundLeafDecoration(
            size: 90,
            rotation: -10,
            opacity: 0.12,
            xOffset: 80,
            yOffset: -200
        )

        // Bottom-right leaf
        BackgroundLeafDecoration(
            size: 70,
            rotation: 25,
            opacity: 0.08,
            xOffset: -80,
            yOffset: -180
        )
    }
}
