//
//  RecordButton.swift
//  HD
//
//  Polished record button with pulsing animation
//

import SwiftUI

struct RecordButton: View {
    let isRecording: Bool
    let action: () -> Void

    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6

    private let buttonSize: CGFloat = 72
    private let iconSize: CGFloat = 28

    var body: some View {
        Button(action: action) {
            ZStack {
                // Outer pulsing ring (only when recording)
                if isRecording {
                    Circle()
                        .stroke(HDColors.recordingRed.opacity(pulseOpacity), lineWidth: 3)
                        .frame(width: buttonSize + 16, height: buttonSize + 16)
                        .scaleEffect(pulseScale)
                }

                // Main button circle
                Circle()
                    .fill(isRecording ? HDColors.recordingRed : HDColors.forestGreen)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(color: (isRecording ? HDColors.recordingRed : HDColors.forestGreen).opacity(0.3), radius: 8, y: 4)

                // Icon
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .onAppear {
            if isRecording {
                startPulseAnimation()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startPulseAnimation()
            } else {
                stopPulseAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        pulseScale = 1.0
        pulseOpacity = 0.6

        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.3
            pulseOpacity = 0.0
        }
    }

    private func stopPulseAnimation() {
        withAnimation(.easeOut(duration: 0.2)) {
            pulseScale = 1.0
            pulseOpacity = 0.0
        }
    }
}

// MARK: - Scale Button Style

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: HDSpacing.xxl) {
        VStack(spacing: HDSpacing.sm) {
            Text("Not Recording")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            RecordButton(isRecording: false) {
                print("Start recording")
            }
        }

        VStack(spacing: HDSpacing.sm) {
            Text("Recording")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            RecordButton(isRecording: true) {
                print("Stop recording")
            }
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
