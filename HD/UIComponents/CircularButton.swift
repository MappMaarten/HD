//
//  CircularButton.swift
//  HD
//
//  Circular button for settings, actions, etc.
//

import SwiftUI

struct CircularButton: View {
    let icon: String
    let action: () -> Void
    var size: CGFloat = 44
    var style: ButtonStyle = .secondary

    enum ButtonStyle {
        case primary    // forestGreen bg, white icon
        case secondary  // paleGreen bg, forestGreen icon
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: return HDColors.forestGreen
        case .secondary: return HDColors.sageGreen
        }
    }

    private var iconColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return HDColors.forestGreen
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(style == .secondary ? HDColors.mutedGreen.opacity(0.3) : Color.clear, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(style == .secondary ? 0.08 : 0), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: HDSpacing.md) {
        CircularButton(icon: "gear", action: {}, style: .secondary)
        CircularButton(icon: "plus", action: {}, style: .primary)
        CircularButton(icon: "xmark", action: {}, size: 32, style: .secondary)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
