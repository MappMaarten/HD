//
//  HikeChip.swift
//  HD
//
//  Small info chips for hike metadata (category, duration, photos, etc.)
//

import SwiftUI

struct HikeChip: View {
    let icon: String?
    let text: String
    var style: ChipStyle = .info

    enum ChipStyle {
        case category  // sageGreen bg, more prominent
        case info      // paleGreen bg, smaller
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(style == .category ? .caption : .caption2)
            }
            Text(text)
                .font(style == .category ? .caption.weight(.medium) : .caption2)
        }
        .foregroundColor(HDColors.forestGreen)
        .padding(.horizontal, style == .category ? HDSpacing.sm : HDSpacing.xs)
        .padding(.vertical, style == .category ? 6 : 4)
        .background(HDColors.sageGreen)
        .cornerRadius(HDSpacing.cornerRadiusSmall)
    }
}

#Preview {
    VStack(spacing: HDSpacing.md) {
        HStack {
            HikeChip(icon: "tree.fill", text: "Boswandeling", style: .category)
            HikeChip(icon: "mountain.2.fill", text: "Bergwandeling", style: .category)
        }

        HStack {
            HikeChip(icon: "clock", text: "7u 0m", style: .info)
            HikeChip(icon: "star.fill", text: "8", style: .info)
            HikeChip(icon: "camera.fill", text: "3", style: .info)
            HikeChip(icon: nil, text: "|||", style: .info)
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
