//
//  ActiveHikeBanner.swift
//  HD
//
//  Warm amber banner showing active hike status
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

            // Embedded hike info card
            HStack(alignment: .top, spacing: HDSpacing.sm) {
                // Date block
                DateBlock(date: hike.startTime)

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HikeChip(icon: hikeTypeIcon, text: hike.type, style: .category)

                    Text(hike.name)
                        .font(.headline)
                        .foregroundColor(HDColors.forestGreen)
                        .lineLimit(1)

                    if let location = hike.startLocationName {
                        Label(location, systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                            .lineLimit(1)
                    }

                    if !hike.companions.isEmpty {
                        Label(hike.companions, systemImage: "person.2.fill")
                            .font(.subheadline)
                            .foregroundColor(HDColors.mutedGreen)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(HDColors.mutedGreen.opacity(0.5))
                    .padding(.top, HDSpacing.xs)
            }
            .padding(HDSpacing.sm)
            .background(HDColors.cardBackground)
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

    return VStack {
        ActiveHikeBanner(hike: hike)
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
