//
//  AudioWaveformView.swift
//  HD
//
//  Elegant waveform visualizer for audio recording
//

import SwiftUI

struct AudioWaveformView: View {
    let level: Float
    var barCount: Int = 30
    var barWidth: CGFloat = 3
    var barSpacing: CGFloat = 2
    var maxHeight: CGFloat = 40

    // Individual bar heights for smooth animation
    @State private var barHeights: [CGFloat] = []
    @State private var animationPhase: Double = 0

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(HDColors.forestGreen.opacity(barOpacity(for: index)))
                    .frame(width: barWidth, height: barHeights.indices.contains(index) ? barHeights[index] : 4)
            }
        }
        .frame(height: maxHeight)
        .onAppear {
            initializeHeights()
            startWaveAnimation()
        }
        .onChange(of: level) { _, newLevel in
            updateHeights(for: newLevel)
        }
    }

    private func initializeHeights() {
        barHeights = (0..<barCount).map { _ in CGFloat(4) }
    }

    private func startWaveAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            animationPhase = 2 * .pi
        }
    }

    private func updateHeights(for level: Float) {
        withAnimation(.easeOut(duration: 0.12)) {
            barHeights = (0..<barCount).map { index in
                calculateBarHeight(for: index, level: level)
            }
        }
    }

    private func calculateBarHeight(for index: Int, level: Float) -> CGFloat {
        let normalizedPosition = Double(index) / Double(barCount - 1)

        // Create a wave pattern that moves from center outward
        let centerDistance = abs(normalizedPosition - 0.5) * 2 // 0 at center, 1 at edges

        // Wave effect based on position and phase - more subtle movement
        let waveOffset = sin(normalizedPosition * 4 * .pi + animationPhase) * 0.25

        // Add secondary wave for more organic movement
        let secondaryWave = sin(normalizedPosition * 2.5 * .pi + animationPhase * 1.3) * 0.15

        // Base height influenced by audio level
        let levelInfluence = Double(level) * (1 - centerDistance * 0.4)

        // Add slight randomness for natural feel
        let randomFactor = Double.random(in: -0.05...0.05)

        // Combine factors with smooth interpolation
        let combinedHeight = max(0.1, min(1.0, levelInfluence + (waveOffset + secondaryWave) * Double(max(level, 0.2)) + randomFactor))

        // Minimum height of 4, max based on maxHeight
        let minHeight: CGFloat = 4
        return minHeight + (maxHeight - minHeight) * CGFloat(combinedHeight)
    }

    // Fade effect towards edges
    private func barOpacity(for index: Int) -> Double {
        let normalizedPosition = Double(index) / Double(barCount - 1)
        let centerDistance = abs(normalizedPosition - 0.5) * 2

        // Full opacity in center, fading to 0.4 at edges
        return 1.0 - centerDistance * 0.6
    }
}

// MARK: - Static Waveform Icon

struct StaticWaveformIcon: View {
    var barCount: Int = 5
    var barWidth: CGFloat = 2
    var barSpacing: CGFloat = 1.5
    var maxHeight: CGFloat = 16
    var color: Color = HDColors.forestGreen

    private let heights: [CGFloat] = [0.4, 0.7, 1.0, 0.7, 0.4]

    var body: some View {
        HStack(spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                RoundedRectangle(cornerRadius: barWidth / 2)
                    .fill(color)
                    .frame(width: barWidth, height: maxHeight * heights[index % heights.count])
            }
        }
        .frame(height: maxHeight)
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        // Active waveform
        VStack(spacing: HDSpacing.sm) {
            Text("Active Waveform (High Level)")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            AudioWaveformView(level: 0.8)
                .padding()
                .background(HDColors.cardBackground)
                .cornerRadius(HDSpacing.cornerRadiusMedium)
        }

        // Medium level
        VStack(spacing: HDSpacing.sm) {
            Text("Medium Level")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            AudioWaveformView(level: 0.5)
                .padding()
                .background(HDColors.cardBackground)
                .cornerRadius(HDSpacing.cornerRadiusMedium)
        }

        // Low level
        VStack(spacing: HDSpacing.sm) {
            Text("Low Level")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            AudioWaveformView(level: 0.2)
                .padding()
                .background(HDColors.cardBackground)
                .cornerRadius(HDSpacing.cornerRadiusMedium)
        }

        // Static icon
        VStack(spacing: HDSpacing.sm) {
            Text("Static Icon")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            StaticWaveformIcon()
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
