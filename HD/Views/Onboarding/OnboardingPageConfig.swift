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

// MARK: - Decorative Icon Configuration

struct DecorativeIconConfig: Identifiable {
    let id = UUID()
    let icon: String
    let angle: Double // degrees around the circle
}

// MARK: - Onboarding Page Configuration

struct OnboardingPageConfig {
    let iconSize: CGFloat
    let decorativeIcons: [DecorativeIconConfig]
    let specialAnimation: SpecialAnimation?

    static func config(for pageIndex: Int) -> OnboardingPageConfig {
        switch pageIndex {
        case 0: // Welcome
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "sun.max.fill", angle: 45),
                    DecorativeIconConfig(icon: "leaf.fill", angle: 225)
                ],
                specialAnimation: .pulse
            )
        case 1: // Observation
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "camera.fill", angle: 45),
                    DecorativeIconConfig(icon: "sparkles", angle: 225)
                ],
                specialAnimation: .breathing
            )
        case 2: // Emotions
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "wind", angle: 45),
                    DecorativeIconConfig(icon: "heart.fill", angle: 225)
                ],
                specialAnimation: .breathing
            )
        case 3: // Journaling
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "sparkle", angle: 45),
                    DecorativeIconConfig(icon: "text.bubble.fill", angle: 225)
                ],
                specialAnimation: .breathing
            )
        case 4: // Map
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "globe.americas.fill", angle: 45),
                    DecorativeIconConfig(icon: "location.fill", angle: 225)
                ],
                specialAnimation: .pulse
            )
        case 5: // Notifications
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "figure.walk", angle: 45),
                    DecorativeIconConfig(icon: "heart.fill", angle: 225)
                ],
                specialAnimation: .sway
            )
        case 6: // Final
            return OnboardingPageConfig(
                iconSize: 220,
                decorativeIcons: [
                    DecorativeIconConfig(icon: "book.fill", angle: 45),
                    DecorativeIconConfig(icon: "arrow.triangle.turn.up.right.diamond.fill", angle: 225)
                ],
                specialAnimation: .pulse
            )
        default:
            return defaultConfig()
        }
    }

    static func defaultConfig() -> OnboardingPageConfig {
        return OnboardingPageConfig(
            iconSize: 220,
            decorativeIcons: [],
            specialAnimation: nil
        )
    }
}
