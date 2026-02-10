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
    let text: String
}

// MARK: - Onboarding Pages Data

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        icon: "figure.hiking",
        title: "Welkom in jouw Wandeldagboek",
        text: "Verhalen, geen stappen.\n\nDit is geen sportapp, maar een persoonlijk dagboek dat je vult terwijl je loopt. Het gaat om beleving, niet om prestaties."
    ),
    OnboardingPage(
        icon: "eye",
        title: "Leg vast wat je ziet",
        text: "Kleine momenten, grote indruk.\n\nEen vogel die je verrast. Een lichtval die je raakt. Leg indrukken vast met foto's, korte notities of symbolen."
    ),
    OnboardingPage(
        icon: "heart.fill",
        title: "Sta stil bij hoe je je voelt",
        text: "Van spanning naar rust.\n\nCheck in bij jezelf voor en na je wandeling. Energie, spanning, stemming — hoe voel je je?"
    ),
    OnboardingPage(
        icon: "book.fill",
        title: "Verbind je gedachten",
        text: "Bewaar wat je beleeft.\n\nWat zie je? Wie spreek je? Waar stop je? Leg je wandeldag vast zoals een logboek. Lees later terug wat je beleefde."
    ),
    OnboardingPage(
        icon: "map.fill",
        title: "Zie waar je geweest bent",
        text: "Jouw persoonlijke wandelkaart.\n\nElke wandeling verschijnt als een marker op de kaart. Ontdek je eigen wandelgeschiedenis."
    ),
    OnboardingPage(
        icon: "bell.fill",
        title: "Blijf verbonden met je ritueel",
        text: "Zachte herinneringen, geen druk.\n\nVriendelijke herinneringen tijdens je wandeling en motivatie om regelmatig te wandelen."
    ),
    OnboardingPage(
        icon: "figure.hiking",
        title: "Jouw tempo, jouw verhaal",
        text: "Geen doelen, alleen aanwezigheid.\n\nDit is je persoonlijke ruimte. Wandel wanneer je wilt. Schrijf wat je wilt. Voor jou."
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
            let granted = await NotificationService.shared.requestPermission()
            await MainActor.run {
                // Sync iOS permission with app settings
                if granted {
                    notificationsEnabled = true
                }
                appState.isOnboarded = true
                dismiss()
            }
        }
    }
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int

    @State private var showIcon = false
    @State private var showDivider = false
    @State private var showTitle = false
    @State private var showText = false

    private var config: OnboardingPageConfig {
        OnboardingPageConfig.config(for: pageIndex)
    }

    var body: some View {
        ZStack {
            // Subtle background leaf decorations
            ForEach(config.leafDecorations) { leaf in
                BackgroundLeafDecoration(
                    size: leaf.size,
                    rotation: leaf.rotation,
                    opacity: leaf.opacity,
                    xOffset: leaf.xOffset,
                    yOffset: leaf.yOffset
                )
            }

            // Clean centered content - no CardView wrapper
            VStack(spacing: 0) {
                Spacer()

                // Icon at 100pt - elegant accent, not hero
                CircularIconView(
                    icon: page.icon,
                    size: config.iconSize,
                    animateRings: true
                )
                .modifier(SpecialIconAnimation(type: config.specialAnimation))
                .opacity(showIcon ? 1 : 0)

                Spacer().frame(height: 32)

                // LeafDivider - elegant separator
                LeafDivider()
                    .opacity(showDivider ? 1 : 0)

                Spacer().frame(height: 28)

                // Title - clean, centered, no notebook background
                Text(page.title)
                    .hdHandwritten(size: 28)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showTitle ? 1 : 0)

                Spacer().frame(height: 24)

                // Split text: bold subtitle + italic description
                textSection
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 8)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            animateEntrance()
        }
    }

    private var textSection: some View {
        let components = page.text.components(separatedBy: "\n\n")
        let subtitle = components.first ?? ""
        let description = components.count > 1 ? components[1] : ""

        return VStack(alignment: .center, spacing: 12) {
            Text(subtitle)
                .font(.custom("Georgia-Bold", size: 17))
                .foregroundColor(HDColors.forestGreen)
                .multilineTextAlignment(.center)

            Text(description)
                .hdSubtitle(size: 16)
                .lineSpacing(5)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    private func animateEntrance() {
        showIcon = false
        showDivider = false
        showTitle = false
        showText = false

        withAnimation(.easeOut(duration: 0.4).delay(0.1)) {
            showIcon = true
        }

        withAnimation(.easeOut(duration: 0.3).delay(0.35)) {
            showDivider = true
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
