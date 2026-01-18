//
//  SplashView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var showOnboarding = false

    var body: some View {
        ZStack {
            Color.green.opacity(0.1)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "figure.hiking")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)

                Text("Wandeldagboek")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("HD - HikeDiary")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingContainerView()
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
}
