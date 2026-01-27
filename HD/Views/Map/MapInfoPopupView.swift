//
//  MapInfoPopupView.swift
//  HD
//
//  First-time info popup explaining the map functionality
//

import SwiftUI

struct MapInfoPopupView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            // Popup content
            VStack(spacing: HDSpacing.sm) {
                // Compact header with icon and title inline
                HStack {
                    Image(systemName: "map")
                        .font(.title2)
                        .foregroundColor(HDColors.forestGreen)

                    Text("Kaart")
                        .font(.headline)
                        .foregroundColor(HDColors.forestGreen)

                    Spacer()

                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(HDColors.mutedGreen)
                    }
                }

                Divider()

                // Info sections - more compact
                VStack(alignment: .leading, spacing: HDSpacing.xs) {
                    InfoRow(
                        icon: "mappin.circle.fill",
                        title: "Jouw wandelingen",
                        description: "Wandelingen met startlocatie worden getoond."
                    )

                    InfoRow(
                        icon: "hand.tap.fill",
                        title: "Tik op een marker",
                        description: "Bekijk details en navigeer naar de wandeling."
                    )

                    InfoRow(
                        icon: "line.3.horizontal.decrease.circle.fill",
                        title: "Filter knop",
                        description: "Filter op type en periode (rechtsonder)."
                    )
                }

                // Inline legend - more compact
                HStack(spacing: HDSpacing.md) {
                    Text("Legenda:")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(HDColors.forestGreen)

                    LegendItem(
                        color: HDColors.amber,
                        label: "Actief"
                    )

                    LegendItem(
                        color: HDColors.forestGreen,
                        label: "Voltooid"
                    )
                }
                .padding(.vertical, HDSpacing.xs)

                // Dismiss button
                PrimaryButton(title: "Begrepen", action: onDismiss)
            }
            .padding(HDSpacing.md)
            .background(HDColors.cardBackground)
            .cornerRadius(HDSpacing.cornerRadiusLarge)
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            .padding(.horizontal, HDSpacing.horizontalMargin)
        }
    }
}

// MARK: - Info Row

private struct InfoRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: HDSpacing.xs) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(HDColors.forestGreen)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(HDColors.forestGreen)

                Text(description)
                    .font(.caption2)
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
    }
}

// MARK: - Legend Item

private struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.caption2)
                .foregroundColor(HDColors.forestGreen)
        }
    }
}

#Preview {
    ZStack {
        HDColors.cream.ignoresSafeArea()

        MapInfoPopupView(onDismiss: {})
    }
}
