import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection

                ScrollView {
                    VStack(spacing: HDSpacing.md) {
                        versionSection
                        madeBySection
                        personalNoteSection
                        brandingSection
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.bottom, HDSpacing.lg)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Terug")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(HDColors.forestGreen)
                }
            }
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Over de app")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Version Section

    private var versionSection: some View {
        FormSection(title: "App informatie", icon: "info.circle") {
            VStack(spacing: HDSpacing.sm) {
                HStack {
                    Text("Versie")
                        .font(.system(size: 15))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Text(appVersion)
                        .font(.system(size: 15))
                        .foregroundColor(HDColors.mutedGreen)
                }

                Divider()
                    .background(HDColors.dividerColor)

                HStack {
                    Text("Build")
                        .font(.system(size: 15))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Text(buildNumber)
                        .font(.system(size: 15))
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }

    // MARK: - Made By Section

    private var madeBySection: some View {
        FormSection(title: "Gemaakt door", icon: "person") {
            VStack(alignment: .leading, spacing: HDSpacing.xs) {
                Text("Mapp Maarten")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(HDColors.forestGreen)

                Text("Indie app developer uit Nederland")
                    .font(.system(size: 14))
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
    }

    // MARK: - Personal Note Section

    private var personalNoteSection: some View {
        FormSection(title: "Persoonlijke noot", icon: "heart") {
            Text("Er zijn genoeg dagboek-apps, maar ik miste iets dat echt voor wandelaars gemaakt is. Daarom heb ik het Wandeldagboek ontwikkeld. In deze app kun je al je wandelingen eenvoudig vastleggen, teruglezen en bijhouden. Het is gebaseerd op mijn eigen ervaring als fanatieke wandelaar. Wandelen geeft energie! Met dit dagboek bewaar je die momenten.")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: HDSpacing.md) {
            Image(systemName: "figure.hiking")
                .font(.system(size: 50))
                .foregroundColor(HDColors.forestGreen)

            Text("Wandeldagboek")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(HDColors.forestGreen)

            Text("Jouw wandelingen, vastgelegd")
                .font(.system(size: 14))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HDSpacing.xl)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
