//
//  CompactMoodSlider.swift
//  HD
//
//  Compact gradient slider for mood selection
//

import SwiftUI

struct CompactMoodSlider: View {
    @Binding var value: Double

    private var moodDescription: String {
        switch Int(value) {
        case 1...3: return "Niet zo lekker"
        case 4...6: return "Gaat wel"
        case 7...8: return "Lekker!"
        case 9...10: return "Super!"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: HDSpacing.xs) {
            // Emoji endpoints with slider
            HStack(spacing: HDSpacing.sm) {
                Text("😔")
                    .font(.title2)

                // Custom gradient slider
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Gradient track background
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "E57373"),  // Red
                                        Color(hex: "FFB74D"),  // Orange
                                        Color(hex: "81C784")   // Green
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 6)
                            .opacity(0.3)

                        // Filled gradient portion
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "E57373"),  // Red
                                        Color(hex: "FFB74D"),  // Orange
                                        Color(hex: "81C784")   // Green
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: thumbPosition(in: geometry.size.width), height: 6)

                        // Thumb
                        Circle()
                            .fill(HDColors.forestGreen)
                            .frame(width: 20, height: 20)
                            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                            .offset(x: thumbPosition(in: geometry.size.width) - 10)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { gesture in
                                        updateValue(from: gesture.location.x, in: geometry.size.width)
                                    }
                            )
                    }
                }
                .frame(height: 20)

                Text("😊")
                    .font(.title2)
            }

            // Description label with value
            Text("\(moodDescription) (\(Int(value)))")
                .font(.subheadline)
                .foregroundColor(HDColors.mutedGreen)
        }
    }

    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let normalized = (value - 1) / 9
        return CGFloat(normalized) * width
    }

    private func updateValue(from x: CGFloat, in width: CGFloat) {
        let normalized = max(0, min(1, x / width))
        let newValue = 1 + (normalized * 9)
        value = round(newValue)
    }
}

#Preview {
    VStack(spacing: HDSpacing.xl) {
        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            CompactMoodSlider(value: .constant(3))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            CompactMoodSlider(value: .constant(7))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            CompactMoodSlider(value: .constant(10))
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
