//
//  LeafDivider.swift
//  HD
//
//  Decorative divider with leaf icon in the center
//

import SwiftUI

struct LeafDivider: View {
    var icon: String = "leaf.fill"
    var color: Color = HDColors.forestGreen
    var lineColor: Color = HDColors.sageGreen
    var lineWidth: CGFloat = 60

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(lineColor)
                .frame(width: lineWidth, height: 1)

            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Rectangle()
                .fill(lineColor)
                .frame(width: lineWidth, height: 1)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        LeafDivider()

        LeafDivider(
            icon: "star.fill",
            color: HDColors.mutedGreen
        )

        LeafDivider(
            lineWidth: 100
        )
    }
    .padding()
    .background(HDColors.cream)
}
