//
//  HikeCardView.swift
//  HD
//
//  Redesigned hike card with horizontal header, dashed divider, notebook lines, and type watermark
//

import SwiftUI

struct HikeCardView: View {
    let hike: Hike

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

    private var formattedDuration: String? {
        guard let endTime = hike.endTime else { return nil }
        let interval = endTime.timeIntervalSince(hike.startTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)u \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func locationText(start: String, end: String?) -> String {
        if let end = end, end != start {
            return "\(start) → \(end)"
        } else {
            return start
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row: Name (full width) + Etappe badge + Chevron
            HStack(spacing: HDSpacing.sm) {
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
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(HDColors.sageGreen.opacity(0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(HDColors.mutedGreen.opacity(0.25), lineWidth: 1)
                    )
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen.opacity(0.5))
            }

            // Dashed divider
            DashedDivider(color: HDColors.dividerColor)
                .padding(.vertical, HDSpacing.sm)

            // Content row: DateBlock + Info + Watermark
            HStack(alignment: .top, spacing: HDSpacing.sm) {
                // Left: DateBlock
                DateBlock(date: hike.startTime)

                // Middle: Info
                VStack(alignment: .leading, spacing: 6) {
                    // Location - met start → end notatie indien beide aanwezig
                    if let startLocation = hike.startLocationName {
                        Label(locationText(start: startLocation, end: hike.endLocationName), systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                            .lineLimit(1)
                    }

                    // Companions
                    if !hike.companions.isEmpty {
                        Label(hike.companions, systemImage: "person.2.fill")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                            .lineLimit(1)
                    }

                    // Stats chips for completed hikes
                    if hike.status == "completed" {
                        statsChipsRow
                            .padding(.top, 4)
                    }
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
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var statsChipsRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row 1: Time + Distance (with text labels)
            HStack(spacing: 6) {
                if let duration = formattedDuration {
                    statChip(icon: "clock", text: duration)
                }

                if let distance = hike.distance {
                    statChip(icon: "figure.walk", text: String(format: "%.1f km", distance))
                }
            }

            // Row 2: Media indicators (icon-only chips)
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
        }
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

// MARK: - StatView (kept for backwards compatibility if needed elsewhere)

struct StatView: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(HDColors.mutedGreen)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(HDColors.forestGreen)
        }
    }
}

#Preview {
    let completedHike = Hike(
        status: "completed",
        name: "Ochtendwandeling Veluwe",
        type: "Boswandeling",
        companions: "Alleen",
        startLocationName: "Apeldoorn",
        startTime: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        endTime: Calendar.current.date(byAdding: .hour, value: 4, to: Calendar.current.date(byAdding: .day, value: -3, to: Date())!),
        distance: 12.5,
        rating: 8
    )

    let inProgressHike = Hike(
        name: "Stadswandeling Amsterdam",
        type: "Stadswandeling",
        companions: "Met Lisa",
        startLocationName: "Amsterdam Centraal",
        startTime: Date()
    )

    let bergHike = Hike(
        status: "completed",
        name: "Bergpad Limburg",
        type: "Bergwandeling",
        companions: "Met familie",
        startLocationName: "Valkenburg",
        startTime: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        endTime: Calendar.current.date(byAdding: .hour, value: 5, to: Calendar.current.date(byAdding: .day, value: -10, to: Date())!),
        distance: 8.3,
        rating: 9
    )

    let lawHike = Hike(
        status: "completed",
        name: "Pieterpad",
        type: "LAW",
        companions: "Alleen",
        startLocationName: "Groningen",
        startTime: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        endTime: Calendar.current.date(byAdding: .hour, value: 6, to: Calendar.current.date(byAdding: .day, value: -5, to: Date())!),
        distance: 24.5,
        rating: 9,
        lawRouteName: "Pieterpad",
        lawStageNumber: 12
    )

    return ScrollView {
        VStack(spacing: HDSpacing.md) {
            HikeCardView(hike: completedHike)
            HikeCardView(hike: inProgressHike)
            HikeCardView(hike: bergHike)
            HikeCardView(hike: lawHike)
        }
        .padding(HDSpacing.horizontalMargin)
    }
    .background(HDColors.cream)
}
