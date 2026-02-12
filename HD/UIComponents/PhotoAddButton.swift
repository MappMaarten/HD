//
//  PhotoAddButton.swift
//  HD
//
//  Circular camera button for adding photos, styled like RecordButton
//

import SwiftUI

struct PhotoAddButton: View {
    let action: () -> Void
    var isDisabled: Bool = false

    private let buttonSize: CGFloat = 72
    private let iconSize: CGFloat = 28

    var body: some View {
        Button(action: action) {
            ZStack {
                // Main button circle
                Circle()
                    .fill(isDisabled ? HDColors.sageGreen : HDColors.forestGreen)
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(
                        color: (isDisabled ? HDColors.sageGreen : HDColors.forestGreen).opacity(0.3),
                        radius: 8,
                        y: 4
                    )

                // Camera icon
                Image(systemName: "camera.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PhotoAddButtonStyle())
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

// MARK: - Button Style

private struct PhotoAddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: HDSpacing.xxl) {
        VStack(spacing: HDSpacing.sm) {
            Text("Active")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            PhotoAddButton {
                print("Add photo")
            }
        }

        VStack(spacing: HDSpacing.sm) {
            Text("Disabled (6/6)")
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)

            PhotoAddButton(action: {}, isDisabled: true)
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
