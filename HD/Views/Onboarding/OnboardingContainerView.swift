//
//  OnboardingContainerView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

// MARK: - Onboarding Page Data Model

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Onboarding Pages Data

private let onboardingPages: [OnboardingPage] = [
    // Page 1: Welkom
    OnboardingPage(
        icon: "figure.hiking",
        title: "Welkom in jouw Wandeldagboek",
        subtitle: "Verhalen, geen stappen",
        description: "Dit is geen sportapp, maar een persoonlijk dagboek dat je vult terwijl je loopt.\nHet gaat om beleving, niet om prestaties."
    ),
    // Page 2: Waarnemen
    OnboardingPage(
        icon: "eye",
        title: "Leg vast wat je ziet",
        subtitle: "Kleine momenten, grote indruk",
        description: "Een vogel die je verrast.\nEen lichtval die je raakt.\nLeg indrukken vast met foto's, korte notities of symbolen."
    ),
    // Page 3: Gevoel
    OnboardingPage(
        icon: "heart.fill",
        title: "Sta stil bij hoe je je voelt",
        subtitle: "Van spanning naar rust",
        description: "Check in bij jezelf voor en na je wandeling.\nEnergie, spanning, stemming - hoe voel je je?"
    ),
    // Page 4: Reflectie
    OnboardingPage(
        icon: "book.fill",
        title: "Verbind je gedachten",
        subtitle: "Bewaar wat je beleeft",
        description: "Wat zie je? Wie spreek je? Waar stop je?\nLeg je wandeldag vast zoals een logboek.\nLees later terug wat je beleefde."
    ),
    // Page 5: Terugkijken
    OnboardingPage(
        icon: "map.fill",
        title: "Zie waar je geweest bent",
        subtitle: "Jouw persoonlijke wandelkaart",
        description: "Elke wandeling verschijnt als een marker op de kaart.\nOntdek je eigen wandelgeschiedenis."
    ),
    // Page 6: Ritme
    OnboardingPage(
        icon: "bell.fill",
        title: "Blijf verbonden met je ritueel",
        subtitle: "Zachte herinneringen, geen druk",
        description: "Vriendelijke herinneringen tijdens je wandeling en motivatie om regelmatig te wandelen."
    ),
    // Page 7: Afsluiting
    OnboardingPage(
        icon: "figure.hiking",
        title: "Jouw tempo, jouw verhaal",
        subtitle: "Geen doelen, alleen aanwezigheid",
        description: "Dit is je persoonlijke ruimte.\nWandel wanneer je wilt.\nSchrijf wat je wilt.\nVoor jou."
    )
]

// MARK: - Onboarding Container View

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private var totalPages: Int { onboardingPages.count }
    private var isLastPage: Bool { currentPage == totalPages - 1 }

    var body: some View {
        ZStack {
            // Background
            HDColors.cream
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Skip button
                HStack {
                    Spacer()
                    if !isLastPage {
                        Button("Overslaan") {
                            withAnimation {
                                currentPage = totalPages - 1
                            }
                        }
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(HDColors.mutedGreen)
                    }
                }
                .padding(.horizontal, HDSpacing.horizontalMargin)
                .padding(.top, HDSpacing.md)
                .frame(height: 44)

                // Content TabView (swipe only)
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicator
                HDPageIndicator(totalPages: totalPages, currentPage: currentPage)
                    .padding(.bottom, HDSpacing.lg)

                // Start button (only on last page)
                if isLastPage {
                    PrimaryButton(title: "Start met wandelen") {
                        completeOnboarding()
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.bottom, HDSpacing.xxl)
                } else {
                    // Empty space for consistent layout
                    Spacer()
                        .frame(height: 80)
                }
            }
        }
    }

    private func completeOnboarding() {
        Task {
            _ = await NotificationService.shared.requestPermission()
            await MainActor.run {
                appState.isOnboarded = true
                dismiss()
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isVisible = false

    var body: some View {
        VStack(spacing: HDSpacing.lg) {
            Spacer()

            // Animated circular icon (no decorations)
            CircularIconView(
                icon: page.icon,
                size: 160,
                animateRings: true
            )
            .id(page.icon) // Force re-render on page change

            // Title - handwritten style
            Text(page.title)
                .hdHandwritten(size: 26)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HDSpacing.horizontalMargin)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 15)

            // Subtitle - Georgia Italic
            Text(page.subtitle)
                .hdSubtitle()
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 15)

            // Leaf divider
            LeafDivider()
                .opacity(isVisible ? 1 : 0)

            // Description
            Text(page.description)
                .hdBody()
                .multilineTextAlignment(.center)
                .padding(.horizontal, HDSpacing.xl)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 15)

            Spacer()
            Spacer()
        }
        .onAppear {
            isVisible = false
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
}
