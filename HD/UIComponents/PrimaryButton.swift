//
//  PrimaryButton.swift
//  HD
//
//  Primary action button with design system styling
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var icon: String? = nil
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            HStack(spacing: HDSpacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }

                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HDSpacing.buttonPadding)
            .padding(.horizontal, HDSpacing.lg)
            .background(isEnabled ? HDColors.forestGreen : HDColors.sageGreen.opacity(0.5))
            .foregroundColor(isEnabled ? .white : HDColors.mutedGreen.opacity(0.5))
            .cornerRadius(HDSpacing.cornerRadiusMedium)
            .shadow(
                color: isEnabled ? HDColors.forestGreen.opacity(0.3) : Color.clear,
                radius: 6,
                x: 0,
                y: 3
            )
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Start Wandeling", action: {}, icon: "figure.walk")
        PrimaryButton(title: "With Icon", action: {}, icon: "play.fill")
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
        PrimaryButton(title: "Disabled with Icon", action: {}, icon: "figure.walk", isEnabled: false)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
