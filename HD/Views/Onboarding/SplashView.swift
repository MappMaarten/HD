//
//  SplashView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var navigateToNext = false
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            HDColors.cream
                .ignoresSafeArea()

            VStack(spacing: HDSpacing.lg) {
                CircularIconView(
                    icon: "figure.hiking",
                    size: 180,
                    animateRings: true
                )

                LeafDivider()
                    .padding(.vertical, HDSpacing.sm)

                VStack(spacing: HDSpacing.xs) {
                    Text("Wandeldagboek")
                        .hdTitle(size: HDTypography.splashTitleSize)

                    Text("Jouw persoonlijke wandeldagboek")
                        .hdSubtitle()
                }
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                opacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                navigateToNext = true
            }
        }
        .fullScreenCover(isPresented: $navigateToNext) {
            if appState.isOnboarded {
                HikesOverviewView()
            } else {
                OnboardingContainerView()
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
}
