//
//  QuickActionButton.swift
//  HD
//
//  Reusable button for quick actions in story/journal views
//

import SwiftUI

struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(HDColors.sageGreen)
            .foregroundColor(HDColors.forestGreen)
            .cornerRadius(HDSpacing.cornerRadiusSmall)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        HStack(spacing: HDSpacing.sm) {
            QuickActionButton(
                icon: "clock",
                title: "Tijdstip",
                action: {}
            )
            QuickActionButton(
                icon: "eye",
                title: "Observatie",
                action: {}
            )
        }

        HStack(spacing: HDSpacing.sm) {
            QuickActionButton(
                icon: "pause.circle",
                title: "Pauze",
                action: {}
            )
            QuickActionButton(
                icon: "hare",
                title: "Dieren gespot",
                action: {}
            )
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cardBackground)
}
