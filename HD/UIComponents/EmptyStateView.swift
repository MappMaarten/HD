//
//  EmptyStateView.swift
//  HD
//
//  Empty state display with circular icon and design system styling
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var useCircularIcon: Bool = true

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            if useCircularIcon {
                CircularIconView(
                    icon: icon,
                    size: 120
                )
            } else {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(HDColors.forestGreen)
            }

            VStack(spacing: HDSpacing.xs) {
                Text(title)
                    .hdTitle(size: HDTypography.cardTitleSize)
                    .multilineTextAlignment(.center)

                Text(message)
                    .hdSubtitle()
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, HDSpacing.xs)
            }
        }
        .padding(HDSpacing.xl)
    }
}

#Preview {
    VStack(spacing: HDSpacing.xl) {
        EmptyStateView(
            icon: "figure.hiking",
            title: "Nog geen wandelingen",
            message: "Start je eerste wandeling om je wandeldagboek te beginnen"
        )

        EmptyStateView(
            icon: "photo",
            title: "No Photos",
            message: "Add photos to capture your memories",
            actionTitle: "Add Photo",
            action: {},
            useCircularIcon: false
        )
    }
    .background(HDColors.cream)
}
