//
//  HikeCardView.swift
//  HD
//
//  Redesigned hike card with date block, category tag, and notebook styling
//

import SwiftUI

struct HikeCardView: View {
    let hike: Hike

    private var hikeTypeIcon: String {
        switch hike.type.lowercased() {
        case let t where t.contains("bos"): return "tree.fill"
        case let t where t.contains("berg"): return "mountain.2.fill"
        case let t where t.contains("strand"): return "beach.umbrella.fill"
        case let t where t.contains("stad"): return "building.2.fill"
        case let t where t.contains("hei"): return "leaf.fill"
        case let t where t.contains("duin"): return "wind"
        default: return "figure.walk"
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

    var body: some View {
        CardView {
            HStack(alignment: .top, spacing: HDSpacing.sm) {
                // Left: DateBlock
                DateBlock(date: hike.startTime)

                // Middle: Content
                VStack(alignment: .leading, spacing: 4) {
                    // Category tag
                    HikeChip(icon: hikeTypeIcon, text: hike.type, style: .category)

                    // Name
                    Text(hike.name)
                        .font(.headline)
                        .foregroundColor(HDColors.forestGreen)
                        .lineLimit(2)

                    // Info row: location · companions (inline)
                    HStack(spacing: 4) {
                        if let location = hike.startLocationName {
                            Label(location, systemImage: "mappin.circle.fill")
                                .lineLimit(1)
                        }

                        if let location = hike.startLocationName, !hike.companions.isEmpty {
                            Text("·")
                        }

                        if !hike.companions.isEmpty {
                            Label(hike.companions, systemImage: "person.2.fill")
                                .lineLimit(1)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen)

                    // Distance row
                    if let distance = hike.distance {
                        Label(String(format: "%.1f km", distance), systemImage: "figure.walk")
                            .font(.caption)
                            .foregroundColor(HDColors.mutedGreen)
                    }

                    // Stats chips for completed hikes
                    if hike.status == "completed" {
                        statsChipsRow
                    }
                }

                Spacer(minLength: 0)

                // Right: Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(HDColors.mutedGreen.opacity(0.5))
            }
        }
    }

    @ViewBuilder
    private var statsChipsRow: some View {
        HStack(spacing: 4) {
            if let duration = formattedDuration {
                compactStatChip(icon: "clock", text: duration)
            }

            if let rating = hike.rating {
                compactStatChip(icon: "star.fill", text: "\(rating)")
            }

            let photoCount = hike.photos?.count ?? 0
            if photoCount > 0 {
                compactStatChip(icon: "camera.fill", text: "\(photoCount)")
            }

            let audioCount = hike.audioRecordings?.count ?? 0
            if audioCount > 0 {
                compactStatChip(icon: "waveform", text: "\(audioCount)")
            }
        }
    }

    private func compactStatChip(icon: String, text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption2)
        .foregroundColor(HDColors.mutedGreen)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(HDColors.sageGreen.opacity(0.5))
        .cornerRadius(4)
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

    return ScrollView {
        VStack(spacing: HDSpacing.md) {
            HikeCardView(hike: completedHike)
            HikeCardView(hike: inProgressHike)
        }
        .padding(HDSpacing.horizontalMargin)
    }
    .background(HDColors.cream)
}
