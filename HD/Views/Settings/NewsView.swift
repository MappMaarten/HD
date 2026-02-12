import SwiftUI

struct NewsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let newsURL = URL(string: "https://www.wandeldagboek.app/nieuws")!

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                titleSection

                ScrollView {
                    VStack(spacing: HDSpacing.md) {
                        descriptionSection
                        tipsSection
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
            Text("Nieuws en updates")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        FormSection(title: "Tips & tricks", icon: "lightbulb") {
            VStack(spacing: 0) {
                tipRow(icon: "bolt.fill", title: "Snelle acties", description: "Gebruik de knoppen boven je verhaal om automatisch een tijdstempel en teller toe te voegen.")

                Divider()

                tipRow(icon: "location.fill", title: "GPS-locatie", description: "Sla je GPS-locatie op bij de start, dan verschijnt je wandeling op de kaart. Zo krijg je een mooi overzicht van plekken waar je hebt gewandeld.")

                Divider()

                tipRow(icon: "camera.fill", title: "Fotoverhaal", description: "Kies bewust 6 foto's die samen het verhaal van je wandeling vertellen.")

                Divider()

                tipRow(icon: "heart.fill", title: "Stemmingsmeter", description: "De stemmingsmeter meet hoe je lichaam zich voelt — vergelijk voor en na je wandeling.")

                Divider()

                tipRow(icon: "mic.fill", title: "Audio-opnames", description: "Neem geluiden of gedachten op onderweg. Ideaal als velddagboek.")
            }
        }
    }

    private func tipRow(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(HDColors.forestGreen)

            Text(description)
                .font(.system(size: 13))
                .foregroundColor(HDColors.mutedGreen)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 40)
        .overlay(alignment: .topLeading) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(HDColors.forestGreen)
                .frame(width: 28, alignment: .center)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        FormSection(title: "Blijf op de hoogte", icon: "newspaper") {
            Text("Volg onze updates en lees blogs over wandelen en nieuwe ontwikkelingen in de app.")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)

            Divider()

            Button {
                openURL(newsURL)
            } label: {
                HStack {
                    Text("Bekijk nieuws")
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
}

#Preview {
    NavigationStack {
        NewsView()
    }
}
