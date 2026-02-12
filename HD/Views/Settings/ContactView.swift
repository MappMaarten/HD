import SwiftUI

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let feedbackURL = URL(string: "https://www.wandeldagboek.app/feedback")!
    private let instagramURL = URL(string: "https://www.instagram.com/wandeldagboek.app")!

    private let contactReasons: [(icon: String, text: String)] = [
        ("lightbulb", "Ideeën voor nieuwe functies"),
        ("questionmark.circle", "Vragen over de app"),
        ("ladybug", "Bugs of problemen melden"),
        ("text.bubble", "Algemene feedback")
    ]

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                backButton
                titleSection

                ScrollView {
                    contentSection
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
            Text("Contact")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: HDSpacing.md) {
            contactSection
            instagramSection
        }
    }

    // MARK: - Contact Section

    private var contactSection: some View {
        FormSection(title: "Neem contact op", icon: "envelope") {
            Text("Heb je vragen, suggesties of wil je samenwerken? Ik hoor graag van je!")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)

            Divider()

            VStack(alignment: .leading, spacing: HDSpacing.md) {
                ForEach(contactReasons, id: \.text) { reason in
                    HStack(spacing: HDSpacing.sm) {
                        Image(systemName: reason.icon)
                            .font(.system(size: 16))
                            .foregroundColor(HDColors.forestGreen)
                            .frame(width: 24)

                        Text(reason.text)
                            .font(.system(size: 14))
                            .foregroundColor(HDColors.forestGreen)
                    }
                }
            }

            Divider()

            Button {
                openURL(feedbackURL)
            } label: {
                HStack {
                    Text("Feedback versturen")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Image(systemName: "paperplane")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }

    // MARK: - Instagram Section

    private var instagramSection: some View {
        FormSection(title: "Volg ons", icon: "person.2") {
            Text("Volg Wandeldagboek op Instagram voor updates, tips en mooie wandelfoto's!")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)

            Divider()

            Button {
                openURL(instagramURL)
            } label: {
                HStack {
                    Text("Volg ons op Instagram")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(HDColors.forestGreen)
                    Spacer()
                    Image(systemName: "link")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(HDColors.mutedGreen)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ContactView()
    }
}
