//
//  SplashView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var opacity: Double = 0
    let isPostOnboarding: Bool

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
                if isPostOnboarding {
                    // After onboarding: navigate to overview
                    appState.navigationPath.append("overview")
                } else {
                    // During onboarding: navigate to onboarding
                    appState.navigationPath.append("onboarding")
                }
            }
        }
        .navigationDestination(for: String.self) { destination in
            switch destination {
            case "onboarding":
                OnboardingContainerView()
            case "overview":
                HikesOverviewView()
            default:
                // Fallback: redirect to onboarding if destination invalid
                OnboardingContainerView()
            }
        }
    }
}

#Preview {
    SplashView(isPostOnboarding: false)
        .environment(AppState())
}
