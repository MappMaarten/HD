//
//  QuickActionPill.swift
//  HD
//
//  Compact pill-style button for quick actions (horizontal scrollable)
//

import SwiftUI

struct QuickActionPill: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(HDColors.cardBackground)
            .foregroundColor(HDColors.forestGreen)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(HDColors.sageGreen, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: HDSpacing.xs) {
            QuickActionPill(
                icon: "clock",
                title: "Tijd",
                action: {}
            )
            QuickActionPill(
                icon: "eye",
                title: "Observatie",
                action: {}
            )
            QuickActionPill(
                icon: "pause.circle",
                title: "Pauze",
                action: {}
            )
            QuickActionPill(
                icon: "hare",
                title: "Dieren",
                action: {}
            )
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
    }
    .background(HDColors.cream)
}
