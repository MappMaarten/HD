//
//  HikeCompletionOverlay.swift
//  HD
//
//  Bottom sheet content shown when a hike is finished
//

import SwiftUI

struct HikeCompletionOverlay: View {
    let hike: Hike
    let onDismiss: () -> Void

    private var duration: String {
        guard let endTime = hike.endTime else { return "–" }
        let interval = endTime.timeIntervalSince(hike.startTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)u \(minutes)m"
        }
        return "\(minutes) min"
    }

    private var distanceText: String {
        guard let distance = hike.distance else { return "–" }
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }

    private var moodText: String {
        guard let endMood = hike.endMood else { return "–" }
        return "\(endMood)/10"
    }

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            CircularIconView(icon: "checkmark", size: 80, animateRings: true)
                .padding(.top, HDSpacing.md)

            VStack(spacing: HDSpacing.xs) {
                Text("Goed gedaan!")
                    .font(.custom("Georgia-Bold", size: 24))
                    .foregroundColor(HDColors.forestGreen)

                Text("Je hebt een wandeling afgerond.\nHopelijk heb je genoten!")
                    .font(.custom("Georgia-Italic", size: 15))
                    .foregroundColor(HDColors.mutedGreen)
                    .multilineTextAlignment(.center)
            }

            // Statistieken grid
            HStack(spacing: HDSpacing.md) {
                StatItem(icon: "ruler", label: "Afstand", value: distanceText)
                StatItem(icon: "clock", label: "Duur", value: duration)
                StatItem(icon: "face.smiling", label: "Stemming", value: moodText)
            }
            .padding(.horizontal, HDSpacing.md)

            PrimaryButton(title: "Bekijk overzicht", action: onDismiss)
                .padding(.horizontal, HDSpacing.xl)
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.bottom, HDSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(HDColors.cream)
    }
}

private struct StatItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: HDSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(HDColors.forestGreen)

            Text(value)
                .font(.custom("Georgia-Bold", size: 16))
                .foregroundColor(HDColors.forestGreen)

            Text(label)
                .font(.custom("Georgia", size: 12))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HDSpacing.sm)
        .background(HDColors.cardBackground)
        .cornerRadius(HDSpacing.cornerRadiusMedium)
    }
}

#Preview {
    HikeCompletionOverlay(
        hike: Hike(
            status: "completed",
            name: "Test Wandeling",
            type: "Dagwandeling",
            startMood: 7
        )
    ) {
        print("Dismissed")
    }
}
