//
//  SplashView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

struct SplashView: View {
    @State private var showIcon = false
    @State private var showTitle = false
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            HDColors.cream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                OnboardingCircularView(
                    icon: "figure.hiking",
                    size: 220,
                    decorativeIcons: [
                        DecorativeIconConfig(icon: "book.fill", angle: 45),
                        DecorativeIconConfig(icon: "arrow.triangle.turn.up.right.diamond.fill", angle: 225)
                    ],
                    accentColor: HDColors.forestGreen
                )
                .modifier(SpecialIconAnimation(type: .pulse))
                .opacity(showIcon ? 1 : 0)

                Spacer().frame(height: 20)

                Text("Wandeldagboek")
                    .font(.custom(HDTypography.handwrittenFont, size: HDTypography.splashTitleSize))
                    .foregroundColor(HDColors.forestGreen)
                    .opacity(showTitle ? 1 : 0)

                Text("Verhalen, geen stappen")
                    .font(.custom(HDTypography.subtitleFont, size: 15))
                    .foregroundColor(HDColors.mutedGreen)
                    .opacity(showTitle ? 1 : 0)
                    .padding(.top, 4)

                Spacer()
                Spacer().frame(height: 60)
            }
        }
        .onAppear {
            animateEntrance()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onComplete()
            }
        }
    }

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            showIcon = true
        }
        withAnimation(.easeOut(duration: 0.4).delay(0.35)) {
            showTitle = true
        }
    }
}

#Preview {
    SplashView(onComplete: {})
}
