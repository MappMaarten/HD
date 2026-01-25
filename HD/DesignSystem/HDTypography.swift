//
//  HDTypography.swift
//  HD
//
//  Design System - Typography Styles
//

import SwiftUI

enum HDTypography {
    // MARK: - Font Names
    static let titleFont = "Georgia-Bold"
    static let subtitleFont = "Georgia-Italic"
    static let handwrittenFont = "BradleyHandITCTT-Bold"

    // MARK: - Font Sizes
    static let splashTitleSize: CGFloat = 32
    static let headerTitleSize: CGFloat = 28
    static let handwrittenSize: CGFloat = 28
    static let cardTitleSize: CGFloat = 22
    static let subtitleSize: CGFloat = 17
    static let bodySize: CGFloat = 16
}

// MARK: - View Modifiers

struct HDTitleStyle: ViewModifier {
    var size: CGFloat = HDTypography.headerTitleSize

    func body(content: Content) -> some View {
        content
            .font(.custom(HDTypography.titleFont, size: size))
            .foregroundColor(HDColors.forestGreen)
    }
}

struct HDSubtitleStyle: ViewModifier {
    var size: CGFloat = HDTypography.subtitleSize

    func body(content: Content) -> some View {
        content
            .font(.custom(HDTypography.subtitleFont, size: size))
            .foregroundColor(HDColors.mutedGreen)
    }
}

struct HDBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: HDTypography.bodySize))
            .foregroundColor(HDColors.forestGreen)
    }
}

struct HDHandwrittenStyle: ViewModifier {
    var size: CGFloat = HDTypography.handwrittenSize

    func body(content: Content) -> some View {
        content
            .font(.custom(HDTypography.handwrittenFont, size: size))
            .foregroundColor(HDColors.forestGreen)
    }
}

// MARK: - View Extensions

extension View {
    func hdTitle(size: CGFloat = HDTypography.headerTitleSize) -> some View {
        modifier(HDTitleStyle(size: size))
    }

    func hdSubtitle(size: CGFloat = HDTypography.subtitleSize) -> some View {
        modifier(HDSubtitleStyle(size: size))
    }

    func hdBody() -> some View {
        modifier(HDBodyStyle())
    }

    func hdHandwritten(size: CGFloat = HDTypography.handwrittenSize) -> some View {
        modifier(HDHandwrittenStyle(size: size))
    }
}
