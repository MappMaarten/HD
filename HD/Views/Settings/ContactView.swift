import SwiftUI

struct ContactView: View {
    private let contactFormURL = URL(string: "https://example.com/contact")!

    var body: some View {
        List {
            Section {
                Text("Heb je vragen, suggesties of wil je een probleem melden? Neem gerust contact met ons op.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }

            Section {
                Link(destination: contactFormURL) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contactformulier")
                                .font(.body)
                            Text("Stuur ons een bericht")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Contact opnemen")
            }

            Section {
                HStack {
                    Text("Reactietijd")
                    Spacer()
                    Text("Binnen 48 uur")
                        .foregroundColor(.secondary)
                }
            } footer: {
                Text("We doen ons best om binnen 48 uur te reageren op je bericht.")
            }
        }
        .navigationTitle("Contact")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ContactView()
    }
}
