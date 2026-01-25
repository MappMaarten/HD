//
//  DashedDivider.swift
//  HD
//
//  Notebook-style dashed line divider
//

import SwiftUI

struct DashedDivider: View {
    var color: Color = HDColors.mutedGreen

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
            .foregroundColor(color)
        }
        .frame(height: 1)
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        Text("Above the line")
        DashedDivider()
        Text("Below the line")

        DashedDivider(color: HDColors.mutedGreen)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
