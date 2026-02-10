import SwiftUI

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let feedbackURL = URL(string: "https://www.wandeldagboek.app/feedback")!

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
                    VStack(spacing: HDSpacing.md) {
                        descriptionSection
                        reasonsSection
                    }
                    .padding(.horizontal, HDSpacing.horizontalMargin)
                }

                buttonSection
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

    // MARK: - Description Section

    private var descriptionSection: some View {
        FormSection {
            Text("Heb je vragen, suggesties of wil je samenwerken? Ik hoor graag van je!")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)
        }
    }

    // MARK: - Reasons Section

    private var reasonsSection: some View {
        FormSection(title: "Neem contact op voor", icon: "envelope") {
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
        }
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        PrimaryButton(
            title: "Feedback versturen",
            action: {
                openURL(feedbackURL)
            },
            icon: "paperplane"
        )
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.vertical, HDSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        ContactView()
    }
}
