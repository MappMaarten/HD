//
//  ActiveHikeBanner.swift
//  HD
//
//  Warm amber banner showing active hike status with embedded card
//

import SwiftUI

struct ActiveHikeBanner: View {
    let hike: Hike

    private var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: hike.startTime)
    }

    private func locationText(start: String, end: String?) -> String {
        if let end = end, end != start {
            return "\(start) → \(end)"
        } else {
            return start
        }
    }

    private var hikeTypeIcon: String {
        let type = hike.type.lowercased()
        switch type {
        // Specifieke matches eerst
        case let t where t.contains("klompen"): return "shoe.2.fill"
        case let t where t.contains("blokje"): return "arrow.triangle.turn.up.right.circle.fill"
        case let t where t.contains("law"): return "signpost.right.fill"

        // Natuur types
        case let t where t.contains("bos"): return "tree.fill"
        case let t where t.contains("berg"): return "mountain.2.fill"
        case let t where t.contains("strand"): return "beach.umbrella.fill"
        case let t where t.contains("hei"): return "leaf.fill"
        case let t where t.contains("duin"): return "wind"

        // Urban/generic
        case let t where t.contains("stad"): return "building.2.fill"
        case let t where t.contains("dag"): return "sun.max.fill"

        default: return "figure.walk"
        }
    }

    private var hikeTypeColor: Color {
        let type = hike.type.lowercased()
        switch type {
        case let t where t.contains("bos"): return HDColors.hikeTypeForest
        case let t where t.contains("berg"): return HDColors.hikeTypeMountain
        case let t where t.contains("strand"): return HDColors.hikeTypeBeach
        case let t where t.contains("stad"): return HDColors.hikeTypeCity
        case let t where t.contains("law"): return HDColors.hikeTypePath
        case let t where t.contains("klompen"): return HDColors.hikeTypeMeadow
        case let t where t.contains("hei"): return HDColors.hikeTypeHeather
        case let t where t.contains("duin"): return HDColors.hikeTypeDune
        case let t where t.contains("blokje"): return HDColors.hikeTypeNeighborhood
        case let t where t.contains("dag"): return HDColors.hikeTypeGeneral
        default: return HDColors.mutedGreen
        }
    }

    var body: some View {
        VStack(spacing: HDSpacing.xs) {
            // Header row
            HStack {
                Label("ONDERWEG", systemImage: "pencil")
                    .font(.caption.weight(.bold))
                Spacer()
                Text("Gestart \(formattedStartTime)")
                    .font(.caption)
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundColor(HDColors.amberDark)

            // Embedded hike info card - matching HikeCardView style
            VStack(alignment: .leading, spacing: 0) {
                // Header row: Name (full width) + Chevron
                HStack(spacing: HDSpacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hike.name)
                            .font(.headline)
                            .foregroundColor(HDColors.forestGreen)
                            .lineLimit(2)

                        // Type label - subtle, handwritten style
                        HStack(spacing: 4) {
                            Image(systemName: hikeTypeIcon)
                                .font(.caption2)
                            Text(hike.type)
                                .font(.custom(HDTypography.handwrittenFont, size: 14))
                        }
                        .foregroundColor(hikeTypeColor)
                    }
                    .padding(.bottom, 2)

                    Spacer(minLength: 0)

                    // Etappe badge (if LAW route)
                    if let stageNumber = hike.lawStageNumber {
                        HStack(spacing: 3) {
                            Image(systemName: "signpost.right.fill")
                                .font(.system(size: 10))
                            Text("Etappe \(stageNumber)")
                                .font(.custom(HDTypography.handwrittenFont, size: 14))
                        }
                        .foregroundColor(HDColors.forestGreen)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(HDColors.sageGreen.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(HDColors.mutedGreen.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                }

                // Dashed divider
                DashedDivider(color: HDColors.dividerColor)
                    .padding(.vertical, HDSpacing.sm)

                // Content row: DateBlock + Info
                HStack(alignment: .top, spacing: HDSpacing.sm) {
                    // Date block
                    DateBlock(date: hike.startTime)

                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        // Location - met start → end notatie indien beide aanwezig
                        if let startLocation = hike.startLocationName {
                            Label(locationText(start: startLocation, end: hike.endLocationName), systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(HDColors.mutedGreen)
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }

                        if !hike.companions.isEmpty {
                            Label(hike.companions, systemImage: "person.2.fill")
                                .font(.subheadline)
                                .foregroundColor(HDColors.mutedGreen)
                                .lineLimit(1)
                        }

                        // Media indicators (icon-only chips)
                        HStack(spacing: 6) {
                            let photoCount = hike.photos?.count ?? 0
                            if photoCount > 0 {
                                statChip(icon: "camera.fill", text: nil)
                            }

                            let audioCount = hike.audioRecordings?.count ?? 0
                            if audioCount > 0 {
                                statChip(icon: "waveform", text: nil)
                            }

                            if !hike.reflection.isEmpty {
                                statChip(icon: "sparkles", text: nil)
                            }
                        }
                        .padding(.top, 4)
                    }

                    Spacer(minLength: 0)
                }
            }
            .padding(HDSpacing.cardPadding)
            .background(
                ZStack {
                    HDColors.cardBackground
                    NotebookLinesBackground()

                    // Type watermark in bottom-right corner
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            HikeTypeWatermark(hikeType: hike.type)
                                .padding(.trailing, -8)
                                .padding(.bottom, -8)
                        }
                    }
                }
            )
            .cornerRadius(HDSpacing.cornerRadiusMedium)
            .shadow(color: Color.black.opacity(0.15), radius: 6, y: 3)
        }
        .padding(HDSpacing.sm)
        .background(HDColors.amberLight)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: HDSpacing.cornerRadiusMedium)
                .stroke(HDColors.amber.opacity(0.3), lineWidth: 2)
        )
    }

    private func statChip(icon: String, text: String?) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
            if let text = text {
                Text(text)
            }
        }
        .font(.caption)
        .foregroundColor(HDColors.mutedGreen)
        .padding(.horizontal, text == nil ? 6 : 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(HDColors.dividerColor.opacity(0.6), lineWidth: 1)
        )
    }
}

#Preview {
    let hike = Hike(
        name: "Ochtendwandeling Veluwe",
        type: "Boswandeling",
        companions: "Alleen",
        startLocationName: "Apeldoorn",
        startTime: Date()
    )

    let bergHike = Hike(
        name: "Klim naar de top",
        type: "Bergwandeling",
        companions: "Met Lisa en Jan",
        startLocationName: "Valkenburg",
        startTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
    )

    return ScrollView {
        VStack(spacing: HDSpacing.md) {
            ActiveHikeBanner(hike: hike)
            ActiveHikeBanner(hike: bergHike)
        }
        .padding(HDSpacing.horizontalMargin)
    }
    .background(HDColors.cream)
}
