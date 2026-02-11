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
    let subtitle: String
    let title: String
    let text: String
    let accentColor: Color
}

// MARK: - Onboarding Pages Data

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "figure.walk",
        subtitle: "Verhalen, geen stappen",
        title: "Welkom in jouw Wandeldagboek",
        text: "Dit is geen sportapp, maar een persoonlijk dagboek dat je vult terwijl je loopt. Het gaat om beleving, niet om prestaties.",
        accentColor: HDColors.forestGreen
    ),
    OnboardingPage(
        icon: "eye",
        subtitle: "Kleine momenten, grote indruk",
        title: "Leg vast wat je ziet",
        text: "Een vogel die je verrast. Een lichtval die je raakt. Leg indrukken vast met foto's, korte notities of symbolen.",
        accentColor: HDColors.forestGreen
    ),
    OnboardingPage(
        icon: "heart.fill",
        subtitle: "Van spanning naar rust",
        title: "Sta stil bij hoe je je voelt",
        text: "Check in bij jezelf voor en na je wandeling. Energie, spanning, stemming—hoe voel je je?",
        accentColor: HDColors.amber
    ),
    OnboardingPage(
        icon: "book.fill",
        subtitle: "Bewaar wat je beleeft",
        title: "Verbind je gedachten",
        text: "Wat zie je? Wie spreek je? Waar stop je? Leg je wandeldag vast zoals een logboek. Lees later terug wat je beleefde.",
        accentColor: HDColors.forestGreen
    ),
    OnboardingPage(
        icon: "map.fill",
        subtitle: "Jouw persoonlijke wandelkaart",
        title: "Zie waar je geweest bent",
        text: "Elke wandeling verschijnt als een marker op de kaart. Ontdek je eigen wandelgeschiedenis.",
        accentColor: HDColors.hikeTypeBeach
    ),
    OnboardingPage(
        icon: "bell.fill",
        subtitle: "Zachte herinneringen, geen druk",
        title: "Blijf verbonden met je ritueel",
        text: "Vriendelijke herinneringen tijdens je wandeling en motivatie om regelmatig te wandelen.",
        accentColor: HDColors.amber
    ),
    OnboardingPage(
        icon: "figure.hiking",
        subtitle: "Geen doelen, alleen aanwezigheid",
        title: "Jouw tempo, jouw verhaal",
        text: "Dit is je persoonlijke ruimte. Wandel wanneer je wilt, schrijf wat je wilt. Voor jou.",
        accentColor: HDColors.forestGreen
    )
]

// MARK: - Onboarding Container View

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
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
                        .font(.custom("Georgia-Italic", size: 15))
                        .foregroundColor(HDColors.mutedGreen)
                        .opacity(0.5)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, HDSpacing.lg)
                .frame(height: 44)

                // Content TabView (swipe only)
                TabView(selection: $currentPage) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index], pageIndex: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicator
                HDPageIndicator(totalPages: totalPages, currentPage: currentPage)
                    .padding(.bottom, HDSpacing.md)

                // Bottom button area
                VStack(spacing: 8) {
                    if isLastPage {
                        PrimaryButton(title: "Start Wandeldagboek", action: {
                            completeOnboarding()
                        }, icon: "figure.hiking")
                        .padding(.horizontal, HDSpacing.horizontalMargin)

                        Text("Begin met vastleggen van jouw wandelbeleving")
                            .font(.custom("Georgia-Italic", size: 13))
                            .foregroundColor(HDColors.mutedGreen)
                            .opacity(0.6)
                            .padding(.top, 4)
                    } else {
                        PrimaryButton(title: "Verder", action: {
                            withAnimation {
                                currentPage += 1
                            }
                        }, icon: "arrow.right")
                        .padding(.horizontal, HDSpacing.horizontalMargin)
                    }
                }
                .padding(.bottom, HDSpacing.xxl)
            }
        }
    }

    private func completeOnboarding() {
        Task {
            let granted = await NotificationService.shared.requestPermission()
            await MainActor.run {
                // Sync iOS permission with app settings
                if granted {
                    notificationsEnabled = true
                    UserDefaults.standard.set(true, forKey: "activeHikeReminderEnabled")
                    UserDefaults.standard.set(true, forKey: "motivationReminderEnabled")
                }
                appState.isOnboarded = true
                dismiss()
            }
        }
    }
}

// MARK: - Onboarding Circular View (wrapper with decorative icons)

struct OnboardingCircularView: View {
    let icon: String
    let size: CGFloat
    let decorativeIcons: [DecorativeIconConfig]
    let accentColor: Color

    @State private var showDecorations = false

    var body: some View {
        ZStack {
            CircularIconView(
                icon: icon,
                size: size,
                animateRings: true,
                ringColor: accentColor.opacity(0.35),
                iconColor: accentColor
            )

            // Decorative floating icons
            ForEach(decorativeIcons) { decorIcon in
                let radius = size / 2 + 20
                let radians = decorIcon.angle * .pi / 180

                Image(systemName: decorIcon.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(accentColor.opacity(0.6))
                    .offset(
                        x: cos(radians) * radius,
                        y: -sin(radians) * radius
                    )
                    .opacity(showDecorations ? 1 : 0)
                    .scaleEffect(showDecorations ? 1 : 0.5)
            }
        }
        .frame(width: size + 60, height: size + 60)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showDecorations = true
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int

    @State private var showIcon = false
    @State private var showSubtitle = false
    @State private var showTitle = false
    @State private var showText = false

    private var config: OnboardingPageConfig {
        OnboardingPageConfig.config(for: pageIndex)
    }

    private var isLastPage: Bool {
        pageIndex == onboardingPages.count - 1
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Large circle with decorative icons
            OnboardingCircularView(
                icon: page.icon,
                size: config.iconSize,
                decorativeIcons: config.decorativeIcons,
                accentColor: page.accentColor
            )
            .modifier(SpecialIconAnimation(type: config.specialAnimation))
            .opacity(showIcon ? 1 : 0)

            Spacer().frame(height: 28)

            // Subtitle - colored accent text
            Text(page.subtitle)
                .font(.custom("Georgia-Bold", size: 17))
                .foregroundColor(page.accentColor)
                .multilineTextAlignment(.center)
                .opacity(showSubtitle ? 1 : 0)

            Spacer().frame(height: 12)

            // Title - large bold serif
            Text(page.title)
                .font(.custom(HDTypography.handwrittenFont, size: 26))
                .foregroundColor(HDColors.forestGreen)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .opacity(showTitle ? 1 : 0)

            Spacer().frame(height: 20)

            // Body text
            Text(page.text)
                .font(.custom("Georgia-Italic", size: 16))
                .foregroundColor(HDColors.mutedGreen)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 8)

            // Walking figures on last page
            if isLastPage {
                Spacer().frame(height: 24)
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        Image(systemName: "figure.walk")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(HDColors.forestGreen.opacity(0.4))
                    }
                }
                .opacity(showText ? 1 : 0)
            }

            Spacer()
            Spacer()
        }
        .onAppear {
            animateEntrance()
        }
    }

    private func animateEntrance() {
        showIcon = false
        showSubtitle = false
        showTitle = false
        showText = false

        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            showIcon = true
        }

        withAnimation(.easeOut(duration: 0.3).delay(0.35)) {
            showSubtitle = true
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.45)) {
            showTitle = true
        }

        withAnimation(.easeOut(duration: 0.4).delay(0.55)) {
            showText = true
        }
    }
}

// MARK: - Special Icon Animation Modifier

struct SpecialIconAnimation: ViewModifier {
    let type: SpecialAnimation?
    @State private var animating = false

    func body(content: Content) -> some View {
        switch type {
        case .pulse:
            content
                .scaleEffect(animating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animating)
                .onAppear { animating = true }
        case .breathing:
            content
                .scaleEffect(animating ? 1.03 : 1.0)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animating)
                .onAppear { animating = true }
        case .sway:
            content
                .rotationEffect(.degrees(animating ? 3 : -3))
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animating)
                .onAppear { animating = true }
        case .none:
            content
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
}
