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
                        .foregroundColor(HDColors.mutedGreen)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                }

                // Dashed divider
                DashedDivider(color: HDColors.sageGreen)
                    .padding(.vertical, HDSpacing.sm)

                // Content row: DateBlock + Info
                HStack(alignment: .top, spacing: HDSpacing.sm) {
                    // Date block
                    DateBlock(date: hike.startTime)

                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        if let location = hike.startLocationName {
                            Label(location, systemImage: "mappin.circle.fill")
                                .font(.subheadline)
                                .foregroundColor(HDColors.amber)
                                .lineLimit(1)
                        }

                        if !hike.companions.isEmpty {
                            Label(hike.companions, systemImage: "person.2.fill")
                                .font(.subheadline)
                                .foregroundColor(HDColors.amber)
                                .lineLimit(1)
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
