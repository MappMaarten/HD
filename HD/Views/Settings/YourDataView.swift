import SwiftUI

struct YourDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let privacyPolicyURL = URL(string: "https://www.wandeldagboek.app/privacy")!

    private var isICloudAvailable: Bool {
        FileManager.default.ubiquityIdentityToken != nil
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                titleSection

                ScrollView {
                    VStack(spacing: HDSpacing.md) {
                        privacyIntroSection
                        iCloudStatusSection
                        importantNoteSection
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                }

            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Back Button

    private var backButton: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(HDColors.forestGreen)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin - 12)
        .padding(.top, HDSpacing.sm)
    }

    // MARK: - Title Section

    private var titleSection: some View {
        HStack {
            Text("Jouw gegevens")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Privacy Intro Section

    private var privacyIntroSection: some View {
        FormSection(title: "Privacy", icon: "hand.raised") {
            Text("Wij slaan geen persoonlijke gegevens op. Je dagboek wordt lokaal opgeslagen en, wanneer iCloud is ingeschakeld, veilig gesynchroniseerd via je eigen iCloud-account. Alleen jij hebt toegang tot deze gegevens.")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)

            Divider()

            Button {
                openURL(privacyPolicyURL)
            } label: {
                HStack {
                    Text("Bekijk privacybeleid")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }

    // MARK: - iCloud Status Section

    private var iCloudStatusSection: some View {
        FormSection(title: "iCloud Status", icon: "icloud") {
            VStack(alignment: .leading, spacing: HDSpacing.sm) {
                // Status indicator
                HStack(spacing: HDSpacing.sm) {
                    Image(systemName: isICloudAvailable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(isICloudAvailable ? HDColors.forestGreen : .orange)

                    Text(isICloudAvailable ? "iCloud is ingeschakeld" : "iCloud is uitgeschakeld")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                }

                Divider()
                    .background(HDColors.dividerColor)

                // Status explanation
                Text(isICloudAvailable
                    ? "Je wandelingen worden automatisch versleuteld opgeslagen en gesynchroniseerd tussen je apparaten. Bij een nieuwe telefoon of herinstallatie komt alles vanzelf terug."
                    : "Je gegevens blijven alleen op dit apparaat staan. Verwijder je de app, dan raak je deze gegevens kwijt.")
                    .font(.system(size: 14))
                    .foregroundColor(HDColors.forestGreen)
                    .lineSpacing(4)

                // Settings link when iCloud is disabled
                if !isICloudAvailable {
                    Divider()
                        .background(HDColors.dividerColor)

                    Button {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            openURL(settingsURL)
                        }
                    } label: {
                        HStack {
                            Text("Open Instellingen")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(HDColors.forestGreen)
                    }
                }
            }
        }
    }

    // MARK: - Important Note Section

    private var importantNoteSection: some View {
        FormSection(title: "Belangrijk", icon: "exclamationmark.triangle") {
            Text("Bij het verwijderen van de app blijven je gegevens alleen bewaard als iCloud is ingeschakeld. Zonder iCloud worden je wandelingen en notities definitief verwijderd.")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)
        }
    }

}

#Preview {
    NavigationStack {
        YourDataView()
    }
}
