import StoreKit
import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                titleSection

                ScrollView {
                    VStack(spacing: HDSpacing.md) {
                        brandingSection
                        personalNoteSection
                        rateAppSection
                        versionSection
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                    .padding(.bottom, HDSpacing.lg)
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
            HStack {
                Text("Versie")
                    .font(.system(size: 15))
                    .foregroundColor(HDColors.forestGreen)
                Spacer()
                Text(appVersion)
                    .font(.system(size: 15))
                    .foregroundColor(HDColors.mutedGreen)
            }
        }
    }

    // MARK: - Personal Note Section

    private var personalNoteSection: some View {
        FormSection(title: "Persoonlijke noot", icon: "heart") {
            VStack(alignment: .leading, spacing: HDSpacing.md) {
                Text("Er zijn genoeg dagboek-apps, maar ik miste iets dat echt voor wandelaars gemaakt is. Daarom heb ik het Wandeldagboek ontwikkeld. In deze app kun je al je wandelingen eenvoudig vastleggen, teruglezen en bijhouden. Het is gebaseerd op mijn eigen ervaring als fanatieke wandelaar.")
                    .font(.system(size: 14))
                    .foregroundColor(HDColors.forestGreen)
                    .lineSpacing(4)

                Text("Wandelen geeft energie! Met dit dagboek bewaar je die momenten.")
                    .font(.system(size: 14))
                    .foregroundColor(HDColors.forestGreen)
                    .lineSpacing(4)
            }
        }
    }

    // MARK: - Branding Section

    private var brandingSection: some View {
        VStack(spacing: HDSpacing.md) {
            Image(systemName: "figure.hiking")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(HDColors.forestGreen)

            Text("Wandeldagboek")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(HDColors.forestGreen)

            Text("Verhalen, geen stappen")
                .font(.system(size: 12))
                .foregroundColor(HDColors.mutedGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HDSpacing.lg)
    }

    // MARK: - Rate App Section

    private var rateAppSection: some View {
        FormSection(title: nil, icon: nil) {
            Button {
                requestReview()
            } label: {
                VStack(spacing: 4) {
                    Text("Ben je blij met de app?")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                    Text("Help andere wandelaars de app te vinden en laat een beoordeling achter.")
                        .font(.system(size: 13))
                        .foregroundColor(HDColors.mutedGreen)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, HDSpacing.xs)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
