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
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(HDSpacing.buttonPadding)
                .background(isEnabled ? HDColors.forestGreen : HDColors.mutedGreen.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(HDSpacing.cornerRadiusMedium)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
