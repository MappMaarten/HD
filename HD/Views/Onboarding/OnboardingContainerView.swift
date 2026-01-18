//
//  OnboardingContainerView.swift
//  HD
//
//  Created by Maarten van Middendorp on 18/01/2026.
//

import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0

    private let totalPages = 7

    var body: some View {
        VStack {
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 40)

            // Content
            TabView(selection: $currentPage) {
                ForEach(0..<totalPages, id: \.self) { page in
                    OnboardingPageView(pageNumber: page + 1)
                        .tag(page)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Button
            if currentPage == totalPages - 1 {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Start Wandelen")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            } else {
                Button {
                    withAnimation {
                        currentPage += 1
                    }
                } label: {
                    Text("Volgende")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    private func completeOnboarding() {
        appState.isOnboarded = true
        dismiss()
    }
}

// MARK: - Onboarding Page
struct OnboardingPageView: View {
    let pageNumber: Int

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundStyle(.green)

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var iconName: String {
        switch pageNumber {
        case 1: return "figure.hiking"
        case 2: return "map"
        case 3: return "camera"
        case 4: return "note.text"
        case 5: return "cloud"
        case 6: return "heart.fill"
        case 7: return "checkmark.circle"
        default: return "figure.hiking"
        }
    }

    private var title: String {
        switch pageNumber {
        case 1: return "Welkom bij Wandeldagboek"
        case 2: return "Volg je Route"
        case 3: return "Leg Momenten Vast"
        case 4: return "Maak Notities"
        case 5: return "Sync met iCloud"
        case 6: return "Bewaar Herinneringen"
        case 7: return "Klaar om te Beginnen"
        default: return "Welkom"
        }
    }

    private var description: String {
        switch pageNumber {
        case 1: return "Bewaar al je wandelingen op één plek"
        case 2: return "Zie je route live op de kaart"
        case 3: return "Maak foto's tijdens je wandeling"
        case 4: return "Schrijf herinneringen en observaties op"
        case 5: return "Al je wandelingen veilig opgeslagen"
        case 6: return "Bekijk je mooiste momenten terug"
        case 7: return "Laten we je eerste wandeling starten!"
        default: return ""
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environment(AppState())
}
