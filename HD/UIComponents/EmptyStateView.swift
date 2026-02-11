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

    @State private var showIcon = false
    @State private var showText = false

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            if useCircularIcon {
                CircularIconView(
                    icon: icon,
                    size: 140,
                    animateRings: true
                )
                .modifier(SpecialIconAnimation(type: .breathing))
                .opacity(showIcon ? 1 : 0)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(HDColors.forestGreen)
                    .opacity(showIcon ? 1 : 0)
            }

            VStack(spacing: HDSpacing.xs) {
                Text(title)
                    .font(.custom("Georgia-Bold", size: 22))
                    .foregroundColor(HDColors.forestGreen)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.custom("Georgia-Italic", size: 16))
                    .foregroundColor(HDColors.mutedGreen)
                    .lineSpacing(5)
                    .multilineTextAlignment(.center)
            }
            .opacity(showText ? 1 : 0)

            if let actionTitle = actionTitle, let action = action {
                PrimaryButton(title: actionTitle, action: action)
                    .padding(.top, HDSpacing.xs)
                    .opacity(showText ? 1 : 0)
            }
        }
        .padding(HDSpacing.xl)
        .onAppear {
            animateEntrance()
        }
    }

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            showIcon = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            showText = true
        }
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
