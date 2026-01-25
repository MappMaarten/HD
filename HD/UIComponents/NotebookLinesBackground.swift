//
//  NotebookLinesBackground.swift
//  HD
//
//  Notebook-style horizontal lines for card backgrounds
//

import SwiftUI

struct NotebookLinesBackground: View {
    var lineSpacing: CGFloat = 20
    var lineColor: Color = HDColors.dividerColor.opacity(0.2)

    var body: some View {
        GeometryReader { geo in
            Path { path in
                var y: CGFloat = lineSpacing
                while y < geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += lineSpacing
                }
            }
            .stroke(lineColor, lineWidth: 0.5)
        }
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        // Preview in a card-like container
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            Text("Ochtendwandeling Veluwe")
                .font(.headline)
                .foregroundColor(HDColors.forestGreen)
            Text("Dit is een voorbeeld van een kaart met notebook lijnen")
                .font(.subheadline)
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HDSpacing.cardPadding)
        .background(
            ZStack {
                HDColors.cardBackground
                NotebookLinesBackground()
            }
        )
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .shadow(color: Color.black.opacity(0.12), radius: 12, y: 4)

        // Different spacing
        RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium)
            .fill(HDColors.cardBackground)
            .frame(height: 100)
            .overlay(
                NotebookLinesBackground(lineSpacing: 15, lineColor: HDColors.mutedGreen.opacity(0.2))
            )
            .cornerRadius(HDSpacing.cornerRadiusMedium)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
