//
//  HikeRatingSlider.swift
//  HD
//
//  Rating slider for hike experience (1-10)
//

import SwiftUI

struct HikeRatingSlider: View {
    @Binding var value: Double

    private var ratingData: (label: String, description: String) {
        switch Int(value) {
        case 1:
            return ("Teleurstellend", "Deze wandeling gaf me weinig; ik zou hem niet opnieuw kiezen.")
        case 2:
            return ("Matig", "Er waren weinig momenten die me bijbleven.")
        case 3:
            return ("Onder gemiddeld", "De wandeling had potentie, maar kwam niet tot zijn recht.")
        case 4:
            return ("Acceptabel", "Prima om gelopen te hebben, maar zonder echte meerwaarde.")
        case 5:
            return ("In orde", "Een degelijke wandeling; niets bijzonders, niets storends.")
        case 6:
            return ("Aangenaam", "Ik heb ervan genoten en zou hem eventueel herhalen.")
        case 7:
            return ("De moeite waard", "Een fijne route met duidelijke pluspunten.")
        case 8:
            return ("Bijzonder", "Deze wandeling verraste me en bleef hangen.")
        case 9:
            return ("Zeer mooi", "Ik liep met plezier en zou deze zeker aanraden.")
        case 10:
            return ("Memorabel", "Een wandeling die klopt in alles en uitnodigt tot herhaling.")
        default:
            return ("In orde", "Een degelijke wandeling; niets bijzonders, niets storends.")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HDSpacing.sm) {
            // Label row with score badge
            HStack {
                Text(ratingData.label)
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
            Text(ratingData.description)
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
            Text("Hoe heb je de wandeling ervaren?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            HikeRatingSlider(value: .constant(1))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe heb je de wandeling ervaren?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            HikeRatingSlider(value: .constant(5))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe heb je de wandeling ervaren?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            HikeRatingSlider(value: .constant(8))
        }

        VStack(alignment: .leading, spacing: HDSpacing.xs) {
            Text("Hoe heb je de wandeling ervaren?")
                .font(.subheadline.weight(.medium))
                .foregroundColor(HDColors.forestGreen)

            HikeRatingSlider(value: .constant(10))
        }
    }
    .padding(HDSpacing.horizontalMargin)
    .background(HDColors.cream)
}
