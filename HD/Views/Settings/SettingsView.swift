import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            List {
                // Account
                Section {
                    NavigationLink(destination: UserDataView()) {
                        SettingsRow(
                            icon: "person.circle",
                            title: "Jouw gegevens",
                            subtitle: "Persoonlijke informatie en sync"
                        )
                    }
                } header: {
                    Text("Account")
                }

                // Wandeling instellingen
                Section {
                    NavigationLink(destination: HikeTypesSettingsView()) {
                        SettingsRow(
                            icon: "figure.walk",
                            title: "Wandeltypes",
                            subtitle: "Beheer je wandeltypes"
                        )
                    }

                    NavigationLink(destination: LAWRoutesSettingsView()) {
                        SettingsRow(
                            icon: "signpost.right",
                            title: "LAW Routes",
                            subtitle: "Langeafstandswandelingen"
                        )
                    }
                } header: {
                    Text("Wandeling")
                }

                // App instellingen
                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        SettingsRow(
                            icon: "bell",
                            title: "Notificaties",
                            subtitle: "Herinneringen en meldingen"
                        )
                    }

                    Button {
                        showOnboarding = true
                    } label: {
                        SettingsRow(
                            icon: "arrow.counterclockwise",
                            title: "Onboarding opnieuw bekijken",
                            subtitle: "Bekijk de introductie opnieuw"
                        )
                    }
                } header: {
                    Text("App")
                }

                // Info
                Section {
                    NavigationLink(destination: AboutView()) {
                        SettingsRow(
                            icon: "info.circle",
                            title: "Over de app",
                            subtitle: "Versie en persoonlijke noot"
                        )
                    }

                    NavigationLink(destination: NewsView()) {
                        SettingsRow(
                            icon: "newspaper",
                            title: "Nieuws & updates",
                            subtitle: "Laatste ontwikkelingen"
                        )
                    }

                    NavigationLink(destination: ContactView()) {
                        SettingsRow(
                            icon: "envelope",
                            title: "Contact",
                            subtitle: "Neem contact met ons op"
                        )
                    }
                } header: {
                    Text("Informatie")
                }
            }
            .navigationTitle("Instellingen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showOnboarding) {
                OnboardingContainerView()
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}
