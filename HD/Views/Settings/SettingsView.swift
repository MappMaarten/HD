import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            ZStack {
                HDColors.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    customHeader
                    titleSection
                    settingsContent
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingContainerView()
            }
        }
    }

    // MARK: - Custom Header

    private var customHeader: some View {
        HStack {
            Spacer()
            CircularButton(icon: "xmark") {
                dismiss()
            }
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Instellingen")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.vertical, HDSpacing.md)
    }

    // MARK: - Settings Content

    private var settingsContent: some View {
        ScrollView {
            VStack(spacing: HDSpacing.md) {
                // Account sectie
                FormSection(title: "Account", icon: "person") {
                    NavigationLink(destination: UserDataView()) {
                        SettingsRow(
                            icon: "person.circle",
                            title: "Jouw gegevens",
                            subtitle: "Persoonlijke informatie en sync"
                        )
                    }
                    .buttonStyle(.plain)
                }

                // Wandeling sectie
                FormSection(title: "Wandeling", icon: "figure.walk") {
                    VStack(spacing: 0) {
                        NavigationLink(destination: HikeTypesSettingsView()) {
                            SettingsRow(
                                icon: "figure.walk",
                                title: "Wandeltypes",
                                subtitle: "Beheer je wandeltypes"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(HDColors.dividerColor)
                            .padding(.vertical, HDSpacing.xs)

                        NavigationLink(destination: LAWRoutesSettingsView()) {
                            SettingsRow(
                                icon: "signpost.right",
                                title: "LAW Routes",
                                subtitle: "Langeafstandswandelingen"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // App sectie
                FormSection(title: "App", icon: "gearshape") {
                    VStack(spacing: 0) {
                        NavigationLink(destination: NotificationsSettingsView()) {
                            SettingsRow(
                                icon: "bell",
                                title: "Notificaties",
                                subtitle: "Herinneringen en meldingen"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(HDColors.dividerColor)
                            .padding(.vertical, HDSpacing.xs)

                        Button {
                            showOnboarding = true
                        } label: {
                            SettingsRow(
                                icon: "arrow.counterclockwise",
                                title: "Onboarding opnieuw bekijken",
                                subtitle: "Bekijk de introductie opnieuw"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Informatie sectie
                FormSection(title: "Informatie", icon: "info.circle") {
                    VStack(spacing: 0) {
                        NavigationLink(destination: AboutView()) {
                            SettingsRow(
                                icon: "info.circle",
                                title: "Over de app",
                                subtitle: "Versie en persoonlijke noot"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(HDColors.dividerColor)
                            .padding(.vertical, HDSpacing.xs)

                        NavigationLink(destination: NewsView()) {
                            SettingsRow(
                                icon: "newspaper",
                                title: "Nieuws & updates",
                                subtitle: "Laatste ontwikkelingen"
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(HDColors.dividerColor)
                            .padding(.vertical, HDSpacing.xs)

                        NavigationLink(destination: ContactView()) {
                            SettingsRow(
                                icon: "envelope",
                                title: "Contact",
                                subtitle: "Neem contact met ons op"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, HDSpacing.horizontalMargin)
            .padding(.bottom, HDSpacing.lg)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: HDSpacing.sm) {
            // Icon zonder achtergrond
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(HDColors.forestGreen)
                .frame(width: 28)

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(HDColors.forestGreen)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(HDColors.mutedGreen)
            }

            Spacer()

            // Chevron
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
        .padding(.vertical, HDSpacing.xs)
    }
}

#Preview {
    SettingsView()
}
