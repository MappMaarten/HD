//
//  ActiveHikePopupView.swift
//  HD
//
//  Custom popup shown when user tries to start a new hike while one is active
//

import SwiftUI

struct ActiveHikePopupView: View {
    let hikeName: String
    let onGoToHike: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background (subtler)
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            // Popup content (compact)
            VStack(spacing: HDSpacing.sm) {
                // Compact message
                VStack(spacing: 4) {
                    Text("Je hebt al een actieve wandeling:")
                        .font(.subheadline)
                        .foregroundColor(HDColors.mutedGreen)

                    Text(hikeName)
                        .font(.body.weight(.semibold))
                        .foregroundColor(HDColors.forestGreen)
                        .multilineTextAlignment(.center)
                }

                // Primary action button
                PrimaryButton(
                    title: "Ga naar wandeling",
                    action: onGoToHike,
                    icon: "arrow.right"
                )

                // Simple text link for cancel
                Button(action: onCancel) {
                    Text("Annuleren")
                        .font(.subheadline)
                        .foregroundColor(HDColors.forestGreen)
                }
                .padding(.top, 4)
            }
            .padding(HDSpacing.md)
            .background(HDColors.cardBackground)
            .cornerRadius(HDSpacing.cornerRadiusLarge)
            .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
            .padding(.horizontal, HDSpacing.horizontalMargin * 1.5)
        }
    }
}

#Preview {
    ZStack {
        HDColors.cream.ignoresSafeArea()

        ActiveHikePopupView(
            hikeName: "Ochtendwandeling door het bos",
            onGoToHike: {},
            onCancel: {}
        )
    }
}
