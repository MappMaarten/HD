//
//  CardView.swift
//  HD
//
//  Generic card container with design system styling
//

import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(HDSpacing.cardPadding)
            .background(HDColors.cardBackground)
            .cornerRadius(HDSpacing.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        CardView {
            Text("This is a card")
                .foregroundColor(HDColors.forestGreen)
        }

        CardView {
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                Text("Card Title")
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)
                Text("Card content goes here")
                    .font(.body)
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
