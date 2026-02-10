//
//  OnboardingPageConfig.swift
//  HD
//
//  Created by Maarten van Middendorp on 10/02/2026.
//

import SwiftUI

// MARK: - Special Animation Types

enum SpecialAnimation {
    case pulse
    case breathing
    case sway
}

// MARK: - Leaf Configuration

struct LeafConfig: Identifiable {
    let id = UUID()
    let size: CGFloat
    let rotation: Double
    let opacity: Double
    let xOffset: CGFloat
    let yOffset: CGFloat
}

// MARK: - Onboarding Page Configuration

struct OnboardingPageConfig {
    let iconSize: CGFloat
    let leafDecorations: [LeafConfig]
    let specialAnimation: SpecialAnimation?

    static func config(for pageIndex: Int) -> OnboardingPageConfig {
        switch pageIndex {
        case 0: // Welcome
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 70, rotation: 15, opacity: 0.08, xOffset: 40, yOffset: 60),
                    LeafConfig(size: 60, rotation: -20, opacity: 0.06, xOffset: -50, yOffset: -150)
                ],
                specialAnimation: .pulse
            )
        case 1: // Observation
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 65, rotation: -10, opacity: 0.07, xOffset: -60, yOffset: 80),
                    LeafConfig(size: 60, rotation: 25, opacity: 0.05, xOffset: 50, yOffset: -180)
                ],
                specialAnimation: nil
            )
        case 2: // Emotions
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 65, rotation: 12, opacity: 0.09, xOffset: 55, yOffset: 70),
                    LeafConfig(size: 70, rotation: -15, opacity: 0.06, xOffset: -45, yOffset: -160)
                ],
                specialAnimation: .breathing
            )
        case 3: // Journaling
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 80, rotation: -8, opacity: 0.08, xOffset: 45, yOffset: 65),
                    LeafConfig(size: 60, rotation: 18, opacity: 0.07, xOffset: -55, yOffset: -170)
                ],
                specialAnimation: nil
            )
        case 4: // Map
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 65, rotation: 20, opacity: 0.07, xOffset: -50, yOffset: 75),
                    LeafConfig(size: 70, rotation: -12, opacity: 0.06, xOffset: 60, yOffset: -165)
                ],
                specialAnimation: nil
            )
        case 5: // Notifications
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 70, rotation: -18, opacity: 0.08, xOffset: 48, yOffset: 68),
                    LeafConfig(size: 60, rotation: 22, opacity: 0.06, xOffset: -52, yOffset: -175)
                ],
                specialAnimation: .sway
            )
        case 6: // Final
            return OnboardingPageConfig(
                iconSize: 100,
                leafDecorations: [
                    LeafConfig(size: 75, rotation: 10, opacity: 0.10, xOffset: -48, yOffset: 72),
                    LeafConfig(size: 65, rotation: -25, opacity: 0.07, xOffset: 55, yOffset: -155),
                    LeafConfig(size: 60, rotation: 15, opacity: 0.05, xOffset: 0, yOffset: -250)
                ],
                specialAnimation: .pulse
            )
        default:
            return defaultConfig()
        }
    }

    static func defaultConfig() -> OnboardingPageConfig {
        return OnboardingPageConfig(
            iconSize: 100,
            leafDecorations: [],
            specialAnimation: nil
        )
    }
}
