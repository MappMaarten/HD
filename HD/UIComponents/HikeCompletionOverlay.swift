//
//  HikeCompletionOverlay.swift
//  HD
//
//  Custom completion popup shown when a hike is finished
//

import SwiftUI

struct HikeCompletionOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: HDSpacing.lg) {
                CircularIconView(icon: "checkmark", size: 100, animateRings: true)

                VStack(spacing: HDSpacing.xs) {
                    Text("Goed gedaan!")
                        .font(.custom("Georgia-Bold", size: 24))
                        .foregroundColor(HDColors.forestGreen)

                    Text("Je hebt een wandeling afgerond.\nHopelijk heb je genoten!")
                        .font(.custom("Georgia-Italic", size: 15))
                        .foregroundColor(HDColors.mutedGreen)
                        .multilineTextAlignment(.center)
                }

                PrimaryButton(title: "Bekijk overzicht", action: onDismiss)
                    .padding(.horizontal, HDSpacing.xl)
            }
            .padding(HDSpacing.xl)
            .background(HDColors.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 20)
            .padding(.horizontal, HDSpacing.horizontalMargin)
        }
    }
}

#Preview {
    HikeCompletionOverlay {
        print("Dismissed")
    }
}
