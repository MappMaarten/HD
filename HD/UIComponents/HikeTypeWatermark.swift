//
//  HikeTypeWatermark.swift
//  HD
//
//  Decorative SF Symbol watermark based on hike type
//

import SwiftUI

struct HikeTypeWatermark: View {
    let hikeType: String

    private var iconName: String {
        switch hikeType.lowercased() {
        case let t where t.contains("bos"): return "tree.fill"
        case let t where t.contains("berg"): return "mountain.2.fill"
        case let t where t.contains("strand"): return "beach.umbrella.fill"
        case let t where t.contains("stad"): return "building.2.fill"
        case let t where t.contains("hei"): return "leaf.fill"
        case let t where t.contains("duin"): return "wind"
        default: return "figure.walk"
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 60))
            .foregroundColor(HDColors.sageGreen.opacity(0.15))
    }
}

#Preview {
    VStack(spacing: HDSpacing.lg) {
        HStack(spacing: HDSpacing.lg) {
            HikeTypeWatermark(hikeType: "Boswandeling")
            HikeTypeWatermark(hikeType: "Bergwandeling")
            HikeTypeWatermark(hikeType: "Strandwandeling")
        }
        HStack(spacing: HDSpacing.lg) {
            HikeTypeWatermark(hikeType: "Stadswandeling")
            HikeTypeWatermark(hikeType: "Heide wandeling")
            HikeTypeWatermark(hikeType: "Duinwandeling")
        }
        HikeTypeWatermark(hikeType: "Normale wandeling")
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
