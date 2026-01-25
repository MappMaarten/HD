//
//  NatureMoodSlider.swift
//  HD
//
//  Nature-themed mood slider for hiking context
//

import SwiftUI

struct NatureMoodSlider: View {
    @Binding var value: Double

    private var moodData: (label: String, description: String) {
        switch Int(value) {
        case 1:
            return ("Verkrampt", "Mijn lichaam voelt zwaar en mijn gedachten zitten vast.")
        case 2:
            return ("Gespannen", "Mijn schouders en adem houden spanning vast.")
        case 3:
            return ("Afgevlakt", "Ik voel weinig energie of kleur.")
        case 4:
            return ("Zoekend", "Ik ben nog niet in mijn ritme.")
        case 5:
            return ("Stil", "Alles is in rust, zonder duidelijke lading.")
        case 6:
            return ("Losser", "Mijn lichaam begint mee te bewegen.")
        case 7:
            return ("In pas", "Ik loop ontspannen en in mijn eigen tempo.")
        case 8:
            return ("Lichtvoetig", "Bewegen gaat makkelijk en voelt fijn.")
        case 9:
            return ("Krachtig", "Ik voel energie door mijn lijf stromen.")
        case 10:
            return ("Verbonden", "Ik voel me één met mijn lichaam en omgeving.")
        default:
            return ("Stil", "Alles is in rust, zonder duidelijke lading.")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            // Label row with score badge
            HStack {
                Text(moodData.label)
                    .font(.body.weight(.semibold))
                    .foregroundColor(HDColors.forestGreen)

                Spacer()

                // Score badge - larger and more prominent
                Text("\(Int(value))")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(HDColors.forestGreen)
                    .clipShape(Circle())
            }

            // Custom gradient slider
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background - subtle neutral tone
                    Capsule()
                        .fill(HDColors.sageGreen.opacity(0.6))
                        .frame(height: 4)

                    // Filled portion - uses forestGreen for consistency
                    Capsule()
                        .fill(HDColors.forestGreen.opacity(0.3))
                        .frame(width: max(0, thumbPosition(in: geometry.size.width)), height: 4)

                    // Thumb - larger and more prominent
                    Circle()
                        .fill(HDColors.forestGreen)
                        .frame(width: 28, height: 28)
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                        .offset(x: thumbPosition(in: geometry.size.width) - 14)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let oldValue = Int(value)
                                    updateValue(from: gesture.location.x, in: geometry.size.width)
                                    let newValue = Int(value)

                                    // Haptic feedback when crossing value boundaries
                                    if newValue != oldValue {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                    }
                                }
                        )
                }
            }
            .frame(height: 28)

            // Description
            Text(moodData.description)
                .font(.custom("Georgia-Italic", size: 13))
                .foregroundColor(HDColors.mutedGreen)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func thumbPosition(in width: CGFloat) -> CGFloat {
        let thumbRadius: CGFloat = 14
        let normalized = (value - 1) / 9
        let trackWidth = width - (thumbRadius * 2)
        return thumbRadius + (CGFloat(normalized) * trackWidth)
    }

    private func updateValue(from x: CGFloat, in width: CGFloat) {
        let thumbRadius: CGFloat = 14
        let trackWidth = width - (thumbRadius * 2)
        let adjustedX = x - thumbRadius
        let normalized = max(0, min(1, adjustedX / trackWidth))
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

            NatureMoodSlider(value: .constant(1))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            NatureMoodSlider(value: .constant(5))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            NatureMoodSlider(value: .constant(8))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe voel je je?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            NatureMoodSlider(value: .constant(10))
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
