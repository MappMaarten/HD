//
//  HDColors.swift
//  HD
//
//  Design System - Color Definitions
//

import SwiftUI

enum HDColors {
    // MARK: - Backgrounds
    static let cream = Color(hex: "D9D0C3")
    static let paleGreen = Color(hex: "C9C0B5")      // Warm taupe for toggle backgrounds

    // MARK: - Primary
    static let forestGreen = Color(hex: "2D5016")

    // MARK: - Secondary
    static let sageGreen = Color(hex: "B8AFA4")      // Warm sage for button backgrounds
    static let mutedGreen = Color(hex: "4A5D3C")     // Darker for better text contrast

    // MARK: - Dividers & Lines
    static let dividerColor = Color(hex: "A89F94")   // Visible lines on cards

    // MARK: - Status Colors
    static let amber = Color(hex: "B8864A")          // Original amber for details
    static let amberLight = Color(hex: "E5CFA0")     // Warm goud - opvallend donkerder
    static let amberDark = Color(hex: "8B6914")      // Original dark amber for text
    static let recordingRed = Color(hex: "B83232")   // Dieper, warmer rood voor opname

    // MARK: - Semantic Aliases
    static let background = cream
    static let primary = forestGreen
    static let secondary = mutedGreen
    static let accent = sageGreen
    static let cardBackground = Color(hex: "E5DED3")
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
