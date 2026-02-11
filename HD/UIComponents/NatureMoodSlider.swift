//
//  NatureMoodSlider.swift
//  HD
//
//  Nature-themed mood slider for hiking context
//

import SwiftUI

struct NatureMoodSlider: View {
    enum MoodContext {
        case pre
        case post
    }

    @Binding var value: Double
    var context: MoodContext = .pre

    private var moodData: (label: String, description: String) {
        switch context {
        case .pre:
            return preMoodData
        case .post:
            return postMoodData
        }
    }

    private var preMoodData: (label: String, description: String) {
        switch Int(value) {
        case 1:
            return ("Verkrampt", "Mijn lichaam voelt zwaar en mijn gedachten zitten vast.")
        case 2:
            return ("Gespannen", "Mijn schouders en adem houden spanning vast.")
        case 3:
            return ("Mat", "Ik voel weinig energie of levendigheid.")
        case 4:
            return ("Onrustig", "Ik zoek nog naar rust in mezelf.")
        case 5:
            return ("Neutraal", "Alles is rustig, zonder duidelijke lading.")
        case 6:
            return ("Wakker", "Ik voel iets bewegen in mijn lijf.")
        case 7:
            return ("Helder", "Mijn gedachten zijn rustig, mijn lijf is aanwezig.")
        case 8:
            return ("Licht", "Ik voel me soepel en vrij.")
        case 9:
            return ("Vol energie", "Ik heb zin om te bewegen.")
        case 10:
            return ("Stralend", "Ik voel me sterk en vol leven.")
        default:
            return ("Neutraal", "Alles is rustig, zonder duidelijke lading.")
        }
    }

    private var postMoodData: (label: String, description: String) {
        switch Int(value) {
        case 1:
            return ("Moe", "De wandeling was zwaar, ik voel me uitgeput.")
        case 2:
            return ("Stijf", "Mijn lijf voelt nog gespannen aan.")
        case 3:
            return ("Vlak", "De wandeling heeft weinig veranderd.")
        case 4:
            return ("Iets rustiger", "Ik voel een klein verschil.")
        case 5:
            return ("Kalm", "De wandeling bracht rust.")
        case 6:
            return ("Losser", "Mijn lichaam is ontspannen.")
        case 7:
            return ("In balans", "Ik voel me aangenaam op mijn plek.")
        case 8:
            return ("Lichtvoetig", "Bewegen heeft me goed gedaan.")
        case 9:
            return ("Energiek", "Ik voel nieuwe kracht.")
        case 10:
            return ("Helemaal goed", "Ik voel me verbonden en vol leven.")
        default:
            return ("Kalm", "De wandeling bracht rust.")
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
