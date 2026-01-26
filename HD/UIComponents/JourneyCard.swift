//
//  JourneyCard.swift
//  HD
//
//  Visual representation of the hike journey from start to end
//

import SwiftUI

struct JourneyCard: View {
    let startLocation: String?
    let startTime: Date
    let startMood: Int
    let endLocation: String?
    let endTime: Date?
    let endMood: Int?

    private var moodChange: Int? {
        guard let endMood = endMood else { return nil }
        return endMood - startMood
    }

    var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: 0) {
                // Start punt
                JourneyPoint(
                    icon: "mappin",
                    location: startLocation ?? "Startpunt",
                    time: formattedTime(startTime),
                    mood: startMood,
                    isFilled: false
                )

                // Verbindingslijn
                HStack(spacing: HDSpacing.sm) {
                    VerticalDashedLine()
                        .frame(width: 24, height: 40)

                    Spacer()
                }
                .padding(.leading, 0)

                // Eind punt
                if let endTime = endTime {
                    JourneyPoint(
                        icon: "mappin.circle.fill",
                        location: endLocation ?? "Eindpunt",
                        time: formattedTime(endTime),
                        mood: endMood,
                        isFilled: true
                    )
                }

                // Stemmingsverandering indicator
                if let change = moodChange {
                    Divider()
                        .padding(.top, HDSpacing.md)

                    moodChangeIndicator(change: change)
                        .padding(.top, HDSpacing.sm)
                }
            }
        }
    }

    @ViewBuilder
    private func moodChangeIndicator(change: Int) -> some View {
        HStack {
            Spacer()

            HStack(spacing: HDSpacing.xs) {
                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                    .font(.subheadline)

                Text(change >= 0 ? "+\(change) stemming" : "\(change) stemming")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(moodChangeColor(for: change))

            Spacer()
        }
    }

    private func moodChangeColor(for change: Int) -> Color {
        if change > 0 {
            return HDColors.forestGreen
        } else if change < 0 {
            return HDColors.recordingRed
        } else {
            return HDColors.secondary
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Journey Point

private struct JourneyPoint: View {
    let icon: String
    let location: String
    let time: String
    let mood: Int?
    let isFilled: Bool

    var body: some View {
        HStack(alignment: .top, spacing: HDSpacing.sm) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isFilled ? HDColors.forestGreen : HDColors.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(location)
                    .font(.headline)
                    .foregroundColor(HDColors.forestGreen)

                Text(time)
                    .font(.subheadline)
                    .foregroundColor(HDColors.secondary)

                if let mood = mood {
                    HStack(spacing: 4) {
                        Image(systemName: "face.smiling")
                            .font(.caption)
                        Text("Stemming: \(mood)/10")
                            .font(.caption)
                    }
                    .foregroundColor(HDColors.mutedGreen)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Vertical Dashed Line

private struct VerticalDashedLine: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 12, y: 0))
                path.addLine(to: CGPoint(x: 12, y: geo.size.height))
            }
            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5, 3]))
            .foregroundColor(HDColors.dividerColor)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: HDSpacing.lg) {
        // Met stemmingsverbetering
        JourneyCard(
            startLocation: "Pieterburen",
            startTime: Date().addingTimeInterval(-3600 * 7),
            startMood: 6,
            endLocation: "Groningen",
            endTime: Date(),
            endMood: 9
        )

        // Met stemmingsdaling
        JourneyCard(
            startLocation: "Amsterdam",
            startTime: Date().addingTimeInterval(-3600 * 4),
            startMood: 8,
            endLocation: "Utrecht",
            endTime: Date(),
            endMood: 5
        )

        // Zonder einde (lopende wandeling)
        JourneyCard(
            startLocation: "Rotterdam",
            startTime: Date(),
            startMood: 7,
            endLocation: nil,
            endTime: nil,
            endMood: nil
        )
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
