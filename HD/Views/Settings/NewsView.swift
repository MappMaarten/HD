import SwiftUI

struct NewsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let newsURL = URL(string: "https://www.wandeldagboek.app/nieuws")!

    var body: some View {
        ZStack {
            HDColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                titleSection
                descriptionSection
                Spacer()
                buttonSection
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
            Text("Nieuws en updates")
                .hdHandwritten(size: 24)
            Spacer()
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.top, HDSpacing.md)
        .padding(.bottom, HDSpacing.sm)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        FormSection(title: "Blijf op de hoogte", icon: "newspaper") {
            Text("Volg onze updates en lees blogs over wandelen en nieuwe ontwikkelingen in de app.")
                .font(.system(size: 14))
                .foregroundColor(HDColors.forestGreen)
                .lineSpacing(4)
        }
        .padding(.horizontal, HDSpacing.horizontalMargin)
    }

    // MARK: - Button Section

    private var buttonSection: some View {
        PrimaryButton(
            title: "Bekijk nieuws",
            action: {
                openURL(newsURL)
            },
            icon: "arrow.up.right"
        )
        .padding(.horizontal, HDSpacing.horizontalMargin)
        .padding(.bottom, HDSpacing.lg)
    }
}

#Preview {
    NavigationStack {
        NewsView()
    }
}
